imgId = 2;
image = imread(sprintf('../images/rectangles/%02d.png', imgId));

%signImg = imread('../images/testImage.jpg');
signImg = imread('../images/signBoard.jpg');
swtImg = swtransform(signImg);
%swtImg = swtransform(image(:, :, [1 1 1]));
figure; imagesc(swtImg);
%components = connectedComponents(swtImg, 3.2);
%figure; imagesc(components);
