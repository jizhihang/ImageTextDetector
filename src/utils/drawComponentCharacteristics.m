function [ drawImage ] = drawComponentCharacteristics(image, characteristics)
    % Function to draw the component characteristics taking in an image
    % and characteristics structure, returned by
    % getComponentCharacteristics
    %
    % Usage:
    % drawImage = drawComponentCharacteristics(image, characteristics)
    %
    % drawImage = Output of image with the characteristics drawn
    % image = Input image to be drawn on
    % characteristics = Characteristic structure that has barycenters,
    % orientation, major and minor axes
    
    % Adding utils for bresenham
    
    % Drawing the characteristic radius
    radiusPen = vision.MarkerInserter('Shape','Circle', 'Size', floor(characteristics.charRadius), ...
                    'BorderColor','Custom','CustomBorderColor',uint8([0 255 0]));
    
    drawImage = step(radiusPen, image, uint32(characteristics.barycenter));
    
    % Drawing the barycenter
    baryPen = vision.MarkerInserter('Shape','Circle','Fill', true, 'Size', 2, ...
                    'FillColor', 'Custom', 'CustomFillColor', uint8([0 0 255]));
    
    drawImage = step(baryPen, drawImage, uint32(characteristics.barycenter));
    
    % Drawing the orientation
    % Getting the line for the orientation from bresenham
    [xPts, yPts] = bresenhamLine(characteristics.barycenter, characteristics.orientation, ...
                                floor(characteristics.charRadius));
    
    % Going along positive direction
    xPts = uint32(xPts(1, :));
    yPts = uint32(yPts(1, :));
    
    % For each channel draw
    color = [255, 0, 0]; % Red
    
    for i = 1:length(xPts)
        drawImage(yPts(i), xPts(i), :) = color;
    end
end

