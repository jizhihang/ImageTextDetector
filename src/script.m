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
[groupedComponents, angles] = groupLetters(signImg, swtImg, components, bboxes);
[chains, chainbboxes] = createChains(groupedComponents, angles, bboxes);
chains = pruneSmallChains(chains, chainbboxes);

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
   components = drawRect(components, [xmin xmax ymin ymax], 100);
   signImg = drawRect(signImg, [xmin xmax ymin ymax], [255, 0, 0]);
   color_idx = color_idx + 1;
end
figure; imagesc(components);
figure; imshow(signImg);
