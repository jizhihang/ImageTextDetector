function[textComponents, componentBboxes] = filterComponents(strokeWidthImg, components)
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
    % componentBBoxes - Bounding boxes containing the components

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set of parameters that can be tuned for better performance
    varianceMeanRatio = 0.7; % Discard if variance > varianceMeanRatio * mean
    maxAspectRatio = 10.0; % Discard if aspect ratio is not between (1/maxAspectRatio, maxAspectRatio)
    diameterStrokeRatio = 10.0; % Discard if diameter is greater than diameterStrokeRatio * mean
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Primary level classifier.
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
        varWidth = sqrt(var(strokeWidthImg(compMembers)));
		widthVariation = varWidth/meanWidth;
		
        % Extract the bounding box
        [rowInds, colInds] = ind2sub(imSize, compMembers);
        rowMin = min(rowInds); rowMax = max(rowInds);
        colMin = min(colInds); colMax = max(colInds);
        rowSpan = rowMax - rowMin; colSpan = colMax - colMin;
		aspectRatio = min(rowSpan/colSpan, colSpan/rowSpan);

        % Get the occupancy ratio
		occupationRatio = length(compMembers)/((rowSpan)*colSpan);
		
		% Need the three parameters to lie within a particular range for
        % accepting it as a component.
        if ( widthVariation <= 1 && ...
             aspectRatio >= 0.1 && aspectRatio <= 1 && ...
             occupationRatio >= 0.1 )
         
            % Storing the bounding boxes for further processing
            compInfo = [compInfo; rowMin rowMax colMin colMax];
            textComponents(compMembers) = noComps + 1;
            noComps = noComps + 1;
        end
    end
    
    %% Auxiliary components elimination.
    
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
        if(noContainments > 2)
            textComponents(textComponents == i) = 0;
        end
    end

    % Re-hashing the components with appropriate indices
    compIds = unique(textComponents(:));
    newCompInfo = zeros(length(compIds) - 1, 4); % Ignoring the zero unique value
    % Scrapping zero
    compIds(compIds == 0) = [];
    % Re-hashing the components and information appropriately
    for i = 1:length(compIds)
        textComponents(textComponents == compIds(i)) = i;
        newCompInfo(i, :) = compInfo(i, :);
    end
    componentBboxes = newCompInfo;
    
    %% Secondary classifier based on Random Forest model obtained from
    %  training data
    
    % implement random forest classifier here.
end
