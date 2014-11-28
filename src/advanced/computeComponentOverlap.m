function [groundLabel, chain] = computeComponentOverlap(compFeatures, gtBox, imageSize)
    % Function to compute the overlap of components with respect to 
    % ground truth cannonical rectangle
    %
    % Inputs:
    % ComponentInformation for all components
    % Ground truth box
    % Image size
    %
    % Output : 
    % A set of 1 or 0 which says positive or negative example (groundLabel)
    % List of ids for 1 examples that form the chain (chain)
    
    thresholdROI = 0.75;
    
    %center = gtBox(3:4) +  0.5 * gtBox(5:6);
    minRow = gtBox(4); maxRow = minRow + gtBox(6);
    minCol = gtBox(3); maxCol = minCol + gtBox(5);
    angle = gtBox(7);
    
    % Rotation matrix
    R = [cos(angle), sin(angle); -1 * sin(angle), cos(angle)];
    
    mask = zeros(imageSize);
    chain = [];
    
    % Label indicating positive example or negative example
    groundLabel = zeros(size(compFeatures, 1), 1);
    for i = 1:size(compFeatures, 1)
        [x, y] = meshgrid(1:imageSize(2), 1:imageSize(1));
        
        % Rotated centre used to draw the circle
        rotCenter = R * compFeatures{i}.center;
        circle = ((x-rotCenter(1)).^2 + (y-rotCenter(2)).^2) ...
                <= compFeatures{i}.radius; 
        
        % Part of the circle within ROI of ground truth
        circleROI = circle(minRow: maxRow, minCol:maxCol);
        
        % Overlap is greater than some threshold, mark it as positive
        % example and consider it a chain for the given text ground truth
        if(sum(circleROI(:)) > thresholdROI * pi * compFeatures{i}.radius^2)
            chain = [chain; i];
            groundLabel(i) = 1;
        end
    end
end

