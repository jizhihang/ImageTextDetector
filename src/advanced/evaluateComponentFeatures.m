function compInfo = evaluateComponentFeatures(components, image, bboxes, swtImg)
    % Function to evaluate the component level features of an image. 
    % Full information will be added later.
    
    compIds = unique(components);
    % Get the gray scale image
    imgray = rgb2gray(image);
    % Get a gradient map.
    [gx, gy] = derivative5(double(imgray), 'x', 'y');
    imgrad =  atan2(gy, gx);
    
    compInfo = [];
    % Get each component's information in series.
    for i = 1:length(compIds)-1
        rowRange = bboxes(i,1):bboxes(i,2);
        colRange = bboxes(i,3):bboxes(i,4);

        comp = components(rowRange, colRange);
        swtComp = swtImg(rowRange, colRange) .* (comp == i);
        gradComp = imgrad(rowRange, colRange);
        chars = getComponentCharacteristics(swtComp, bboxes(i, :));
        % Get the component contour by dilating the component and
        % subtracting it with the component.
        compContour = zeros(length(rowRange), length(colRange));
        compContour(comp == i) = 1;
        dilatedContour = imdilate(compContour, ones(3,3));
        compContour = dilatedContour - compContour;
        % We are not sure about the single pixel thick contour. Dilate it
        % to twice or thrice the thickness for robust results.
        compContour = imdilate(compContour, ones(3,3));
        % Get the gradients on the contour and the component itself.
        gradContour = gradComp.*compContour;
        gradComp = gradComp.*(comp == i);
        
        % Debug.
        %figure; imagesc([gradContour gradComp]);
        
        % Get the component information.
        compMap = zeros(size(compContour));
        compMap(comp == i) = 1;
        compInfoStruct = getComponentInformation(compMap, chars, ...
                                                 gradContour, gradComp, ...
                                                 swtComp);
        compInfo = [compInfo compInfoStruct];
    end
end