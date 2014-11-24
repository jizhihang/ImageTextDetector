function compFeat = evaluateComponentFeatures(image, swtImage, components, bboxes)
    % Function to evaluate the component level features of an image. The
    % function returns a set of features for each component which will be
    % used for training a random forest classifier in the training phase
    % and used for pruning non-text candidates in the testing phase.
    % 
    % Input:
    %       image: Input image.
    %       swtImage: Stroke Width Transform of the image.
    %       components: Matrix of the same size of image containing
    %       component numbers for each component.
    %       bboxes: Bounding boxes for each component.
    %
    %Output:
    %   compFeat: Cell of structs with the following entries:
    %           .contourShape: HoG for the contour of the component.
    %           .edgeShape: HoG for the component.
    %           .occupationRatio: Histogram of densities per each sector in
    %               the template.
    %           .AxialRatio: Ratio of the major axis to minor axis of the
    %               component.
    %           .widthVariation: mean SWT / std dev SWT of the component.
    %           .density: Ratio of number of foreground pixels to
    %               characteristic area of the component.
    %           .bbox: Bounding box of the component.
    %           .size: Characteristic radius of the component.
    %           .center: Center of the component.
    %           .direction: Majore orientation of the component.
    
    compIds = unique(components);
    % Get the gray scale image
    imgray = rgb2gray(image);
    % Get a gradient map.
    [gx, gy] = derivative5(double(imgray), 'x', 'y');
    imgrad =  atan2(gy, gx);
    
    compFeat = {};
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
                                                 swtComp, bboxes(i,:));
        compFeat{i} = compInfoStruct;
    end
end
