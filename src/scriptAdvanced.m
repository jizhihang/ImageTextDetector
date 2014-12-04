clear all;

%% Load the files in the directories.
addpath(genpath('advanced'));
addpath(genpath('lib'));
addpath(genpath('utils'));

% Load the model for components and chain random forests
% Loads componentModel and chainModel
load('models.mat');

% Load image.
%image = imresize(imread('../ICDAR/img_23.jpg'), 0.25);
image = imresize(imread('../MSRA-TD500/test/IMG_1869.JPG'), 0.4);

% Get Stroke Width Transform.
tic
swtImg = swtransform(image, false);
imwrite(uint8(swtImg*255.0/max(swtImg(:))), 'swt_image.png');

% Get connected components.
tic
rawComponents = connectedComponents(swtImg, 3.1);
toc

% Filter the components using heuristics.
tic
[components, bboxes] = filterComponents(swtImg, rawComponents);
toc
figure; imagesc([components, rawComponents]);

% Draw component bounding boxes.
compImage = image;
for idx=1:1:length(unique(components))-1
	compImage = drawRect(compImage, bboxes(idx, :), [255, 0, 0]);
end
figure; imshow(compImage);
imwrite(compImage, 'raw_components.png');

% Eliminating components based on the random tree model and features
[newComps, bboxes, compProbs, compFeat] = pruneComponents(image, swtImg, components, bboxes, componentModel);

% View the component characteristics.
charImage = image;
compImage = image;
for idx = 1:1:length(unique(newComps))
	[xidx, yidx] = find(newComps == idx);
	if isempty(xidx)
		continue;
	end
	xmin = min(xidx); ymin = min(yidx);
	xmax = max(xidx); ymax = max(yidx);
	bbox = [xmin xmax ymin ymax];
	compImage = drawRect(compImage, bbox, [255, 0, 0]);
	compSWT = swtImg(xmin:xmax, ymin:ymax);
	compChars = getComponentCharacteristics(compSWT, bbox);
	charImage = drawComponentCharacteristics(charImage, compChars);
end
figure; imshow(compImage);
imwrite(compImage, 'pruned_components.png');

% Debugging
%figure; imagesc(components)
%figure; imagesc(newComps)
components = newComps;

% Debug.
%annotatedImage = annotateComponents(image, components);
%figure; imshow(annotatedImage);


% Get chains using heirarchical clustering.
tic
[members, ~] = clusterChains(compFeat, components);
toc

% Draw chain boxes.
chainImg = image;
for mIdx = 1:numel(members)
	chain = members{mIdx}
	rIdx = []; cIdx = [];
	for idx = chain
		[r, c] = find(components == idx);
		rIdx = [rIdx r']; cIdx = [cIdx c'];
	end
	rMin = min(rIdx); rMax = max(rIdx);
	cMin = min(cIdx); cMax = max(cIdx);
	chainImg = drawRect(chainImg, [rMin rMax cMin cMax], [255, 0, 0]);
end
figure; imshow(chainImg);
imwrite(chainImg, 'initial_chains.png');
% Weeding out unecessarily using random forests
tic
[members, clusterImg] = pruneChains(image, components, members, compFeat,...
                            compProbs, chainModel);
chainImg = image;
mask = zeros(size(components));
for mIdx = 1:numel(members)
	chain = members{mIdx}
	rIdx = []; cIdx = [];
	for idx = chain
		[r, c] = find(components == idx);
		rIdx = [rIdx r']; cIdx = [cIdx c'];
	end
	rMin = min(rIdx); rMax = max(rIdx);
	cMin = min(cIdx); cMax = max(cIdx);
	mask(rMin:rMax, cMin:cMax) = 1;
	chainImg = drawRect(chainImg, [rMin rMax cMin cMax], [255, 0, 0]);
end
figure; imshow(chainImg);
imwrite(chainImg, 'pruned_chains.png');

% Run OCR.
maskedImg = uint8(double(rgb2gray(image)).*mask);
bwThres = graythresh(maskedImg);
bwImg = im2bw(maskedImg, bwThres);
ocrOutput = ocr(bwImg);
ocrImg = insertObjectAnnotation(image, 'rectangle', ocrOutput.WordBoundingBoxes, ocrOutput.Words);
ocrOutputMask = ocrOutput;
bwImgMask = bwImg;

imwrite(ocrImg, 'ocr_output_masked.png');

% Try vanilla for comparison
bwThres = graythresh(image);
bwImg = im2bw(image, bwThres);
ocrOutput = ocr(bwImg);
ocrImg = insertObjectAnnotation(image, 'rectangle', ocrOutput.WordBoundingBoxes, ocrOutput.Words);
ocrOutputVanilla = ocrOutput;

imwrite(ocrImg, 'ocr_output_vanilla.png');

toc
figure; imagesc(clusterImg);

drawImage = image;
boxInserter = vision.ShapeInserter('Shape', 'Polygons', 'Fill', true, 'FillColor', 'White');
tightBBoxes = getTightBoundingBox(members, clusterImg, compFeat);
ocrImg = chainImg;
for mIdx = 1:numel(members)
	chain = members{mIdx}
	rIdx = []; cIdx = [];
	for idx = chain
		[r, c] = find(components == idx);
		rIdx = [rIdx r']; cIdx = [cIdx c'];
	end
	bbox = round(minBoundingBox([rIdx; cIdx]));
	mask = zeros(size(components));
	mask = step(boxInserter, mask, reshape(bbox([2 1], :), 1, 8));
	mask(mask ~= 0) = 1;
	maskedIm = image.*uint8(mask(:,:, [1 1 1]));
	angle = tightBBoxes(mIdx, 5);
	maskedIm = imrotate(maskedIm, -angle*180/pi, 'bilinear', 'crop');
	bwThres = graythresh(maskedIm);
	bwImg = im2bw(maskedIm, bwThres);
	ocrOutput = ocr(1 - bwImg);
	cString = '';
	for idx = 1:numel(ocrOutput.Words)
		cString = [cString ocrOutput.Words{idx} ' '];
	end
	fprintf('Detected string is %s\n', cString);
	ocrImg = insertText(ocrImg, [min(cIdx), min(rIdx)], cString);
	drawImage = drawLine(drawImage, bbox(:,1)', bbox(:,2)', [255,0,0]);
	drawImage = drawLine(drawImage, bbox(:,2)', bbox(:,3)', [255,0,0]);
	drawImage = drawLine(drawImage, bbox(:,3)', bbox(:,4)', [255,0,0]);
	drawImage = drawLine(drawImage, bbox(:,4)', bbox(:,1)', [255,0,0]);
end

figure; imshow(drawImage)
imwrite(drawImage, 'final_image.png');
