% Script to batch process images in the vanilla mode.

clear all;

addpath(genpath('vanilla'));
addpath(genpath('lib'));
addpath(genpath('utils'));

% Get the directory
imageList = dir('../Dataset/');

for nIdx=3:1:numel(imageList)
    fprintf('Processing %s\n', imageList(nIdx).name);
    tic;
    image = imresize(imread(sprintf('../Dataset/%s',imageList(nIdx).name)), 0.5);

    % Perform the positive ray operations.
    swtImgP = swtransform(image, false);
    components = connectedComponents(swtImgP, 3.0);
    [componentsP, bboxes] = filterComponents(swtImgP, components);
    [groupedComponents, angles] = groupLetters(image, swtImgP, componentsP, bboxes);
    [chainsP, chainbboxes] = createChains(groupedComponents, angles, bboxes);
    chainsP = pruneSmallChains(chainsP, chainbboxes);

    % Perform the negative ray operations.
    swtImgN = swtransform(image, true);
    components = connectedComponents(swtImgN, 3.0);
    [componentsN, bboxes] = filterComponents(swtImgN, components);
    [groupedComponents, angles] = groupLetters(image, swtImgN, componentsN, bboxes);
    [chainsN, chainbboxes] = createChains(groupedComponents, angles, bboxes);
    chainsN = pruneSmallChains(chainsN, chainbboxes);

    % Create bounding boxes for the chains.
    drawImg = image;
    mask = zeros(size(componentsP));
    chainedComponents = zeros(size(componentsP));
    colorIdx = 1;
    % Positive ray components
    for idx=1:1:numel(chainsP)
        chain = chainsP{idx};
        for cNum=chain
            chainedComponents(componentsP == cNum) = colorIdx;
        end
        [x, y] = find(chainedComponents == colorIdx);
        xmin = min(x); xmax = max(x); 
        ymin = min(y); ymax = max(y);
        mask(xmin:xmax,ymin:ymax) = 1;
        
        drawImg = drawRect(drawImg, [xmin xmax ymin ymax], [255, 0, 0]);
        colorIdx = colorIdx + 1;
    end
    % Negative ray components
    chainedComponents = zeros(size(componentsP));
    colorIdx = 1;
    for idx=1:1:numel(chainsN)
        chain = chainsN{idx};
        for cNum=chain
            chainedComponents(componentsN == cNum) = colorIdx;
        end
        [x, y] = find(chainedComponents == colorIdx);
        xmin = min(x); xmax = max(x); 
        ymin = min(y); ymax = max(y);
        mask(xmin:xmax,ymin:ymax) = 1;
        
        drawImg = drawRect(drawImg, [xmin xmax ymin ymax], [0, 0, 255]);
        colorIdx = colorIdx + 1;
    end
    
    % Run OCR now.
    maskedImg = uint8(double(rgb2gray(image)).*mask);

    bwThres = graythresh(maskedImg);
    bwImg = im2bw(maskedImg, bwThres);

    ocrOutput = ocr(bwImg);
    ocrImg = insertObjectAnnotation(drawImg, 'rectangle', ...
                                    ocrOutput.WordBoundingBoxes,...
                                    ocrOutput.Words);
    % Save the image.
    imwrite(ocrImg, sprintf('output/%s', imageList(nIdx).name));
    finishedTime = toc;
    fprintf('Time taken = %f\n', finishedTime);
end
