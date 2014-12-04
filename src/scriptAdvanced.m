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

% Weeding out unecessarily using random forests
tic
[members, clusterImg] = pruneChains(image, components, members, compFeat,...
                            compProbs, chainModel);
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
    bbox = tightBBoxes(j, :);
    rotCorner = round(rotateCannonicalBox(tightBBoxes(j, :)));

	% Draw the rectangle
	drawImage = drawLine(drawImage, rotCorner(1, :), rotCorner(2, :), [255,0,0]);
	drawImage = drawLine(drawImage, rotCorner(2, :), rotCorner(3, :), [255,0,0]);
	drawImage = drawLine(drawImage, rotCorner(3, :), rotCorner(4, :), [255,0,0]);
	drawImage = drawLine(drawImage, rotCorner(4, :), rotCorner(1, :), [255,0,0]);

	rotCorners{j} = rotCorner;
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
