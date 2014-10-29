function[textComponents] = filterComponents(strokeWidthImg, components)
    % This function performs some fairly flexible tests based on some fairly general rules 
    % on connected components of swt image. 
    %
    % Usage:
    % textComponents = filterComponents(strokeWidthImg, components)
    %
    % Input:
    % strokeWidthImg - image containing the stroke widths of the pixels
    % Components - Image containing indices of the component to which each pixel belongs
    %
    % Output:
    % textComponents - Components that most likely correspond to text regions
    %

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set of parameters that can be tuned for better performance
    varianceMeanRatio = 0.7; % Discard if variance > varianceMeanRatio * mean
    maxAspectRatio = 10.0; % Discard if aspect ratio is not between (1/maxAspectRatio, maxAspectRatio)
    diameterStrokeRatio = 10.0; % Discard if diameter is greater than diameterStrokeRatio * mean

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Number of components in the original segmentation
    maxCompId = max(components(:));
    imSize = size(strokeWidthImg);
    % Initialization
    textComponents = zeros(imSize);
    % Tracking the index of valid components
    noComps = 0;

    % Collecting components to perform containment test
    compInfo = [];

    % Process each component to weed out non-text segments
    for compId = 1:maxCompId
        compMembers = find(components == compId);

        % Mean value of swt in the image
        meanWidth = mean(strokeWidthImg(compMembers));
        varWidth = var(strokeWidthImg(compMembers));

        % Ignoring this part, check NOTE below
        % Discard if the variance is too large
        if(varWidth > varianceMeanRatio * meanWidth)
            continue;
        end

        % Extract the bounding box
        [rowInds colInds] = ind2sub(imSize, compMembers);
        rowMin = min(rowInds); rowMax = max(rowInds);
        colMin = min(colInds); colMax = max(colInds);
        rowSpan = rowMax - rowMin; colSpan = colMax - colMin;

        % Discarding the component if the height is not within [10, 300]
        if(rowSpan < 10 || rowSpan > 300)
            continue;
        end
            
        % Aspect ratio constraint along with diameter constraint
        if (rowSpan > maxAspectRatio * colSpan ...
                || colSpan > maxAspectRatio * rowSpan ...
                || hypot(rowSpan, colSpan) > diameterStrokeRatio *  meanWidth)
            continue;
        end

        % NOTE : Variance based elimination removes Es and Xs.
        % Debugging; needs thorough investigation
        % Connected components have very high stroke widths, 
        % Xs and Es are problematic; need to recheck the whole pipeline wrt these two characters
        %fprintf('( %f %f %f ) %d\n', varWidth, meanWidth, varWidth / meanWidth, ...
        %                                        length(compMembers));

        %mask = zeros(imSize);
        %mask(compMembers) = 1;
        %figure(1); imagesc(mask)
        %figure(2); imagesc(strokeWidthImg.*mask);
        %pause();
    
        compInfo = [compInfo; rowMin rowMax colMin colMax noComps+1];

        textComponents(compMembers) = noComps + 1;
        noComps = noComps + 1;
    end
    
    % Finding the components that contain more than two other components and discarding them
    % Taking the brute force approach for now
    % Might need to dynamically change the components later
    for i = 1:size(compInfo, 1)
        % Outer box
        outerBox = compInfo(i, 1:4);
        noContainments = 0;

        % Checking the containment of bounding boxes against all other boxes
        for j = 1:size(compInfo, 1)
            % Ignoring the comparision with itself
            if(j == i) 
                continue;
            end
            
            % Inner box containment
            % Might have to add some tolerance later for robustness
            innerBox = compInfo(j, 1:4);
            if(outerBox(1) <= innerBox(1) && outerBox(2) >= innerBox(2) && ...
                outerBox(3) <= innerBox(3) && outerBox(4) >= innerBox(4))
                noContainments = noContainments + 1;
            end
        end

        %Debugging
        %fprintf('Containments : %d \n', noContainments);
        % If there are containments, ignore the current component
        if(noContainments > 0)
            textComponents(textComponents == compInfo(i, 5)) = 0;
        end
    end

    % Re-hashing the components with appropriate indices
    compIds = unique(textComponents(:));
    % Scrapping zero
    compIds(compIds == 0) = [];
    % Re-hashing the components appropriately
    for i = 1:length(compIds)
        textComponents(textComponents == compIds(i)) = i;
    end
end
