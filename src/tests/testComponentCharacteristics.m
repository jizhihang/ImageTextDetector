clear all;
%% Load the files in the directories.
addpath(genpath('../vanilla'));
addpath(genpath('../lib'));
addpath(genpath('../utils'));

%% Main script begins.
imgId = 2;
%image = imread(sprintf('../images/rectangles/%02d.png', imgId));

%image = imread('../images/testImage.jpg');
%image = imresize(imread('../images/beachPark.jpg'), 0.25);
image = imresize(imread('../../Dataset/img_121.jpg'), 1.0);
%image = imread('../images/signBoard.jpg');

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Testing the characteristics visually
% Components
compIds = unique(components(:));

drawImage = components(:,:,[1 1 1]);%image;
% For each component, excluding zero
for i = 1:length(compIds)-1
    rowRange = bboxes(i,1):bboxes(i,2);
    colRange = bboxes(i,3):bboxes(i,4);
    
    comp = components(rowRange, colRange);
    swtComp = swtImg(rowRange, colRange) .* (comp == i);
    
    chars = getComponentCharacteristics(swtComp, bboxes(i, :));
    
    % Drawing bounding boxes and characteristics;
    drawImage = drawComponentCharacteristics(drawImage, chars);
end

figure ; imshow(drawImage)