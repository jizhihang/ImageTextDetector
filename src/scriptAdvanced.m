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
image = imresize(imread('../MSRA-TD500/train/IMG_0155.JPG') , 0.5);

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

% Eliminating components based on the random tree model and features
[newComps, bboxes, compProbs, compFeat] = pruneComponents(image, swtImg, components, bboxes, componentModel);

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

% Weeding out unecessarily using random forests
tic
[members, clusterImg] = pruneChains(image, components, members, compFeat,...
                            compProbs, chainModel);
toc
figure; imagesc(clusterImg);

% Get tight bounding boxes.
tightBBoxes = getTightBoundingBox(members, components, compFeat);

cornerPen = vision.MarkerInserter('Shape','Circle', ...
               'BorderColor','Custom','CustomBorderColor',uint8([0 255 0]));

% Rotating them to get rotated points
rotCorners = {};
drawImage = image;
for j = 1:size(tightBBoxes, 1)
    rotCorners{j} = rotateCannonicalBox(tightBBoxes(j, :));
    drawImage = step(cornerPen, drawImage, uint32(rotCorners{j}));
end
figure; imshow(drawImage)
%rotCorners

   
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
