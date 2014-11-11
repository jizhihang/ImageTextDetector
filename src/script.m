clear all;

imgId = 2;
image = imread(sprintf('../images/rectangles/%02d.png', imgId));

%signImg = imread('../images/testImage.jpg');
%signImg = imresize(imread('../images/beachPark.jpg'), 0.25);
signImg = imresize(imread('../Dataset/img_121.jpg'), 0.5);
%signImg = imread('../images/signBoard.jpg');

tic
swtImg = swtransform(signImg);
toc
%swtImg = swtransform(image(:, :, [1 1 1]));

%figure; imagesc(swtImg);
tic
rawComponents = connectedComponents(swtImg, 3.2);
toc
tic
[components, bboxes] = filterComponents(swtImg, rawComponents);
toc

%subplot(1,2,1); imagesc(components)
%subplot(1,2,2); imagesc(rawComponents)

annotatedImage = annotateComponents(signImg, components);
figure; imshow(annotatedImage);

tic
[groupedComponents, angles] = groupLetters(signImg, swtImg, components, bboxes);
toc

recImage = drawComponentPairs(annotatedImage, groupedComponents, bboxes);
figure; imshow(recImage)
return;
tic
[chains, chainbboxes] = createChains(groupedComponents, angles, bboxes);
toc

tic
chains = pruneSmallChains(chains, chainbboxes);
toc

% Color the components.
color_idx = 1;
chained_components = zeros(size(components));
for idx=1:1:size(chains,1)
   chain = chains{idx};
   for cnum=chain
       chained_components(components == cnum) = color_idx;
   end
   [x, y] = find(chained_components == color_idx);
   xmin = min(x); xmax = max(x);
   ymin = min(y); ymax = max(y);
   components = drawRect(components, [xmin xmax ymin ymax], 10);
   signImg = drawRect(signImg, [xmin xmax ymin ymax], [255, 0, 0]);
   color_idx = color_idx + 1;
end
figure; imagesc(components);
figure; imshow(signImg);
