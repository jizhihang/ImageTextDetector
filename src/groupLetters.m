function[grouping, angles] = groupLetters(image, strokeWidthImg, components, compInfo)
    % This function performs grouping of components to identify text on a single line
    %
    % Usage:
    % groupedComponents = groupLetters(image, strokeWidthImg, components)
    %
    % Input:
    % image - RGB image for which strokeWidthImg and components have been extracted
    % strokeWidthImg - image containing the stroke widths of the pixels
    % Components - Image containing indices of the component to which each pixel belongs
    % compInformation - Information of bounding boxes for the components after basic filtering
    %
    % Output:
    % groupedComponents - Components that most likely correspond to text regions
    %

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set of parameters that can be tuned for better performance
    heightRatio = 2.0 ; % Ratio of the heights
    strokeWidthRatio = 2.0; % Ratio of median of stroke widths
    distanceWidthRatio = 3.0; % Ratio between distance between them and maximum width
    colorDistance = 5.0; % Distance between their colors in the LAB color space

    angleThreshold = pi/18; % Threshold in collecting pairs of components from same text

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Number of components in the original segmentation

    noComps = max(components(:));
    imSize = size(image);

    % Converting the image into LAB space for color comparision
    [L, a, b] = RGB2Lab(image);
    
    % Matrix indicating the final grouping between the components
    grouping = false(noComps);
    angles = zeros(noComps);
    for compId = 1:noComps-1

        %Attributes to compare for the current component
        center = 0.5 * [compInfo(compId, 1) + compInfo(compId, 2), ...
                        compInfo(compId, 3) + compInfo(compId, 4)];
        colSpan = compInfo(compId, 4) - compInfo(compId, 3);  
        rowSpan = compInfo(compId, 2) - compInfo(compId, 1);  

        members = components == compId;
        medianWidth = median(strokeWidthImg(members));
        meanColor = [mean(L(members)), mean(a(members)), mean(b(members))];

        for i = compId+1:noComps
            % Attributes to compare for this particular component
            curCenter = 0.5 * [compInfo(i, 1) + compInfo(i, 2), ...
                            compInfo(i, 3) + compInfo(i, 4)];
            curColSpan = compInfo(i, 4) - compInfo(i, 3);
            curRowSpan = compInfo(i, 2) - compInfo(i, 1);
           
            % Checking if distance between them is comparable to width
            if(norm(center - curCenter) > distanceWidthRatio * max(curColSpan, colSpan))
                continue;
            end

            % If heights are comparable
            if(rowSpan > heightRatio * curRowSpan || curRowSpan > heightRatio * rowSpan)
                continue;
            end
            
            curMembers = components == i;
            curMedianWidth = median(strokeWidthImg(curMembers));
            % If median of stroke width are comparable
            if(curMedianWidth > strokeWidthRatio * medianWidth || ...
                medianWidth > strokeWidthRatio * curMedianWidth)
                continue;
            end

            % Checking for closeness in color space
            curMeanColor = [mean(L(curMembers)), mean(a(curMembers)), mean(b(curMembers))];
            if(norm(curMeanColor - meanColor) > colorDistance)
                continue;
            end

            % Declaring the components to be from the same text; calculating the angle
            grouping(compId, i) = true;
            grouping(i, compId) = true;
            
            % Some ordered computation of angle
            [~, maxId] = max([curCenter(1), center(1)]);
            if(maxId == 1)
                angle = atan2(curCenter(2) - center(2), curCenter(1) - center(1));
            else
                angle = atan2(center(2) - curCenter(2), center(1) - curCenter(1));
            end

            angles(compId, i) = angle;
            angles(i, compId) = angle;
        end
    end
end
