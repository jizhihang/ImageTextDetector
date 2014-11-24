% Script to generate ground truth from the MSRA dataset

% Reading the images in the training folder
trainImgPath = '../../MSRA/train/%s';
trainImgs = dir(sprintf(trainImgPath, '*.jpg'));

noImgs = length(trainImgs);

for i = 1:20 %noImgs
    % Reading each image
    imagePath = sprintf(trainImgPath, trainImgs(i).name);
    image = imread(imagePath);
    %figure(1); imshow(image)

    % Reading the ground truth for the image
    trainLabelPath = strrep(imagePath, '.JPG', '.gt');
    labels = dlmread(trainLabelPath);

    % Visualizing the bounding boxes 
    ptMarker = vision.MarkerInserter('Shape','Circle','Fill', true, 'Size', 5, ...
                    'FillColor', 'Custom', 'CustomFillColor', uint8([255 0 0]));

    centerMarker = vision.MarkerInserter('Shape','Circle','Fill', true, 'Size', 5, ...
                    'FillColor', 'Custom', 'CustomFillColor', uint8([0 0 255]));
    
    drawImage = image;

    % Trasforming the points
    centerPts = labels(:, 3:4)  + labels(:, 5:6) * 0.5;

    drawPts = [];
    for j = 1:size(centerPts, 1)
        % Angle of rotation
        angle =  -1 * labels(j, 7);
        % Rotation matrix
        R = [cos(angle), sin(angle); -sin(angle), cos(angle)];

        centerPt = centerPts(j, :);
        shifts = 0.5 * labels(j, 5:6);
        % Getting four corners of the cannonical box
        corners = [[1, 1] .* shifts; [-1, 1] .* shifts; ...
                   [-1 -1] .* shifts; [1 -1].*shifts];  
        
        % Rotating the corners and translate to the center
        corners = bsxfun(@plus, (R * corners')',  centerPt);

        drawPts = [drawPts; corners];
    end
    
    if
    drawImage = step(centerMarker, drawImage, uint32(centerPts));
    drawImage = step(ptMarker, drawImage, uint32(drawPts));

    figure(2); imshow(drawImage)
    pause(3);
end
