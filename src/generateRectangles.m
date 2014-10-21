% Script to generate arbitrarily oriented rectangles with various shapes
% and heights

noImgs = 20;

fileName = '../images/rectangles/%02d.png';
imgDim = 200;

%Well behaved rectangle
rectangle = zeros(imgDim);
rectangle(70:130, 50:150) = 1;  
imwrite(rectangle, sprintf(fileName , 1), 'png');

%Generating rectangles (random)
for i = 2:noImgs
    % Randomly selected size and orientation for rectangles
    width = randi([20, 150]); 
    height = randi([70, 150]);
    angle = randi([-90, 90]);
    
    %Creating and rotating the rectangle
    rectangle = zeros(imgDim);
    rectangle(imgDim/2 + (-floor(height/2) : floor(height/2)) , ...
                imgDim/2 + (-floor(width/2) : floor(width/2))) = 1;
    rectangle = imrotate(rectangle, angle, 'bilinear');
    
    %Writing the rectangles to ../images/rectangle/
    imwrite(rectangle, sprintf(fileName, i), 'png');
end
