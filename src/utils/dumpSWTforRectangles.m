%Local script to read images from ../images/rectangles/* and dump their swt transforms

%Adding the path
addpath('../src/');
basePath = '../images/rectangles';
%imgList = dir(fullfile(basePath, '*.png'));

%For each image, find and dump the swt image
noImgs = 20;
for i = 1:noImgs
    image = imread(fullfile(basePath, sprintf('%02d.png', i)));
    swtImg = swtransform(image(:, :, [1 1 1]));
    
    %Dumping the swtImg as such
    save(fullfile(basePath, sprintf('swt%02d.mat', i)), 'swtImg');

    %Replacing Inf with a large number (naive way of doing things)
    infIndices = find(swtImg == Inf);
    swtImg(infIndices) = -1;
    maxVal = max(swtImg(:));
    swtImg(infIndices) = maxVal;
    swtImg = swtImg / maxVal;
    %combImg = [image / max(image(:)), swtImg / 500] * 255;
    rgbMap = label2rgb(gray2ind(swtImg, 255), jet(255));
    
    %Writing the image side by side
    %imshow([image(:, :, [1 1 1]), rgbMap]);
    %fullfile(basePath, strrep(imgList(i).name, '.png', '_swt.png'))
    imwrite([image(:, :, [1 1 1]) rgbMap], fullfile(basePath, sprintf('%02d_swt.png', i)), 'png');
end

