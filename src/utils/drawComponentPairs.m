function[recImage] = drawComponentPairs(image, grouping, compInfo)
    % Function to show the pairs of components in bounding boxes
    % Input:
    % grouping : Matrix that shows the grouping of pairs of components
    % Component Infomation : bouding boxes for all the components
    
    noComps = size(grouping, 1);
    upMatrix = triu(grouping);
    
    [comp1, comp2] = ind2sub([noComps, noComps], find(upMatrix == 1));
    noMatches = length(comp1);
    
    recImage = image;
    for i = 1:noMatches
        box1 = compInfo(comp1(i), 1:4);
        box2 = compInfo(comp2(i), 1:4);
        
        % Boxes extend
        minRow = min(box1(1), box2(1));
        maxRow = max(box1(2), box2(2));
        minCol = min(box1(3), box2(3));
        maxCol = max(box1(4), box2(4));
        
        % Save the image separately.
        tmpImg = drawRect(image, [minRow, maxRow-1, minCol, maxCol-1], [255.0, 0.0, 0.0]);
        imwrite(tmpImg, sprintf('../output/image_%d.png', i));
        recImage = drawRect(recImage, [minRow, maxRow-1, minCol, maxCol-1], [255.0, 0.0, 0.0]);
    end
end