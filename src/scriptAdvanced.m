clear all;

%% Load the files in the directories.
addpath(genpath('advanced'));
addpath(genpath('lib'));
addpath(genpath('utils'));

%% Main script starts.
imgId = 2;
%image = imread(sprintf('../images/rectangles/%02d.png', imgId));

%signImg = imread('../images/testImage.jpg');
%signImg = imresize(imread('../images/beachPark.jpg'), 0.25);
image = imresize(imread('../MSRA-TD500/train/IMG_0063.jpg'), 0.5);
%signImg = imresize(imread('../Dataset/img_121.jpg'), 0.5);
%signImg = imread('../images/signBoard.jpg');

tic
swtImg = swtransform(image, false);
toc
%swtImg = swtransform(image(:, :, [1 1 1]));

%figure; imagesc(swtImg);
tic
rawComponents = connectedComponents(swtImg, 3.2);
toc
tic
[components, bboxes] = filterComponents(swtImg, rawComponents);
toc

% Extracting the component features
compFeatures = evaluateComponentFeatures(image, swtImg, components, bboxes);

tic;
[clusters, clusterImg] = clusterChains(compFeatures, components);
toc;

figure; imagesc(components)
figure; imagesc(clusterImg)
return

%subplot(1,2,1); imagesc(components)
%subplot(1,2,2); imagesc(rawComponents)

%annotatedImage = annotateComponents(signImg, components);
%figure; imshow(annotatedImage);

tic
[groupedComponents, angles] = groupLetters(signImg, swtImg, components, bboxes);
toc

recImage = drawComponentPairs(annotatedImage, groupedComponents, bboxes);
figure; imshow(recImage)

tic
[chains, chainbboxes] = createChains(groupedComponents, angles, bboxes);
toc

tic
chains = pruneSmallChains(chains, chainbboxes);
toc

% Get component features.
compFeat = evaluateComponentFeatures(signImg, swtImg, components, bboxes);
probabilities = ones(1,numel(compFeat));
chainFeat = evaluateChainFeatures(signImg, components, chains, compFeat, probabilities, angles);
return;
% Color the components.
color_idx = 1;
chained_components = zeros(size(components));
drawComponents = components;
for idx=1:1:size(chains,1)
   chain = chains{idx};
   for cnum=chain
       chained_components(components == cnum) = color_idx;
   end
   [x, y] = find(chained_components == color_idx);
   xmin = min(x); xmax = max(x);
   ymin = min(y); ymax = max(y);
   drawComponents = drawRect(drawComponents, [xmin xmax ymin ymax], 10);
   signImg = drawRect(signImg, [xmin xmax ymin ymax], [255, 0, 0]);
   color_idx = color_idx + 1;
end
figure; imagesc(drawComponents);
figure; imshow(signImg);
