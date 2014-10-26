imgId = 9;
image = imread(sprintf('../images/rectangles/%02d.png', imgId));

%signImg = imread('../images/signBoard.jpg');
%swtImg = swtransform(signImg);
swtImg = swtransform(image(:, :, [1 1 1]));
figure; imagesc(swtImg);
