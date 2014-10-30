imgId = 2;
image = imread(sprintf('../images/rectangles/%02d.png', imgId));

%signImg = imread('../images/testImage.jpg');
signImg = imresize(imread('../images/beachPark.jpg'), 0.25);
%signImg = imread('../images/signBoard.jpg');
swtImg = swtransform(signImg);
%swtImg = swtransform(image(:, :, [1 1 1]));

%figure; imagesc(swtImg);
components = connectedComponents(swtImg, 3.2);
%figure; imagesc(components);
[components, bboxes] = filterComponents(swtImg, components);
%figure; imagesc(components)
groupedComponents = groupLetters(signImg, swtImg, components, bboxes);

return
% Viewing each component seperately 
for i = 1:length(unique(components))
    imagesc(components == i)
    pause()
end
