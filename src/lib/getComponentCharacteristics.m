function [characteristics] = getComponentCharacteristics(componentSWT, componentInfo)
    % Function to get the characteristics of a component given its SWT
    % that is used as the probability distribution
    % 
    % Usage : 
    % characteristics = getComponentCharacteristics(componentSWT, compInformation)
    %
    % componentSWT = SWT image in the bbox of the component
    % componentInfo = Bounding box information of the component, 
    %                   [minRow, maxRow, minCol, maxCol] format
    %
    % characteristics = struct with following properties
    % .barycenter = [xBary, yBary] + [minCol minRow]
    % .relCenter = [xBary, yBary]
    % .majorAxis = Length of the major axis
    % .minorAxis = Length of the minor axis
    % .charRadius = Characteristic radius = mean of minor and major axes
    % .orientation = Orientation of the major axis wrt x-axis in
    %                positive direction (theta)
    
    % Generating the moments
    [xId, yId] = meshgrid(1:size(componentSWT, 2), 1:size(componentSWT, 1));
    
    % M00 = normalization
    % Normalization factor as is it used as a probability map
    M00 = sum(componentSWT(:));
    
    % M11 
    M11 = xId .* yId .* componentSWT;
    M11 = sum(M11(:));
    
    % M20
    M20 = xId .* xId .* componentSWT;
    M20 = sum(M20(:));
    
    % M02
    M02 = yId .* yId .* componentSWT;
    M02 = sum(M02(:));
    
    % Barycenters = xBary, yBary
    yBary = yId .* componentSWT;
    yBary = sum(yBary(:))/M00;
    xBary = xId .* componentSWT;
    xBary = sum(xBary(:))/M00;
    
    % Theta computation (a,b,c are written from the paper)
    a = M20/M00 - xBary^2;
    b = 2 * (M11/M00 - xBary * yBary);
    c = M02/M00 - yBary^2;
    
    theta = 0.5 * atan(2*b/(a-c));
    majorAxis = sqrt(0.5*((a+c) + sqrt(b^2 + (a-c)^2)));
    minorAxis = sqrt(0.5*((a+c) - sqrt(b^2 + (a-c)^2)));
    
    % Final assignments
    minRow = componentInfo(1); minCol = componentInfo(3);
    characteristics.barycenter = [xBary, yBary] + [minCol, minRow];
    characteristics.relCenter = [xBary, yBary];
    characteristics.orientation = theta;
    characteristics.majorAxis = majorAxis;
    characteristics.minorAxis = minorAxis;
    characteristics.charRadius = sum([majorAxis, minorAxis]);
end

