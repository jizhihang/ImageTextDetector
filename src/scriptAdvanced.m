clear all;

%% Load the files in the directories.
addpath(genpath('advanced'));
addpath(genpath('lib'));
addpath(genpath('utils'));

% Load the model for components and chain random forests
% Loads componentModel and chainModel
%load('models.mat');

% Load image.
image = imresize(imread('../Dataset/img_23.jpg'), 0.5);

% Get Stroke Width Transform.
tic
swtImg = swtransform(image, true);
toc

% Get connected components.
tic
rawComponents = connectedComponents(swtImg, 3);
toc

% Filter the components using heuristics.
tic
[components, bboxes] = filterComponents(swtImg, rawComponents);
toc

% Eliminating components based on the random tree model
[components, bboxes] = pruneComponents(image, swtImg, components, bboxes, componentModel);

% Debug.
annotatedImage = annotateComponents(image, components);
figure; imshow(annotatedImage);

% Get component features.
tic
[compFeat, compProbabilities] = evaluateComponentFeatures(image, swtImg, components, bboxes);
toc

% Get chains using heirarchical clustering.
tic
[members, clusterImg] = clusterChains(compFeat, components);
toc

% Weeding out unecessarily using random forests
tic
members = pruneChains(image, components, members, compFeat,...
                            compProbabilities, chainModel);
toc

figure; imagesc(clusterImg);
%% -------- Debug later ---------
% Color the components.
%color_idx = 1;
%chained_components = zeros(size(components));
%drawComponents = components;
%for idx=1:1:size(chains,1)
%   chain = chains{idx};
%   for cnum=chain
%       chained_components(components == cnum) = color_idx;
%   end
%   [x, y] = find(chained_components == color_idx);
%   xmin = min(x); xmax = max(x);
%   ymin = min(y); ymax = max(y);
%   drawComponents = drawRect(drawComponents, [xmin xmax ymin ymax], 10);
%   signImg = drawRect(signImg, [xmin xmax ymin ymax], [255, 0, 0]);
%   color_idx = color_idx + 1;
%end
%figure; imagesc(drawComponents);
%figure; imshow(signImg);
