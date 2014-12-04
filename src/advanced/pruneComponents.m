function [components, bboxes, compProbs, compFeat] = pruneComponents(...
                        image, swtImg, components, bboxes, componentModel)
    % Function to take in the required parameters along with components 
    % along with their features, performs classification based on random
    % forests and predicts if they are actual components or not
    %
    % USage:
    % [components, bboxes, compProbs, compFeat] = pruneComponents(image, swtImg, ...
    %                               components, bboxes, componentModel);
    %
    % Input:
    % image = RGB image
    % swtImg = Strokewidth image for RGB image
    % components = Image that indicates Membership of all the pixels wrt
    %               components
    % bboxes = Bounding boxes for all the components
    % componentModel = Random forest for the components, used to classify
    %
    % Output:
    % Components = Cleaned up components
    % bboxes = Cleaned up bounding boxes
    % compProbs = Probability that a corresponding component is classified
    % compFeat = Cleaned up component Features 
    %
    
    % Evaluate features for the components
    compFeat = evaluateComponentFeatures(image, swtImg, components, bboxes);
    
    % Predict the label for components
    noFeatures = 120;
    noComps = size(bboxes, 1);
    Xtest = zeros(noComps, noFeatures);
    for i = 1 : noComps
        curComp = compFeat{i};
        Xtest(i, :) = [curComp.contourShape, curComp.edgeShape, ...
                        curComp.occupationRatio, curComp.AxialRatio, ...
                        curComp.widthVariation, curComp.density];
    end
    
    [Ytest, probTest] = componentModel.predict(Xtest);
    Ytest = cell2mat(Ytest);
    
    % Discard the negatively classified components
    notComponents = find(Ytest == 0);
    for i = 1:length(notComponents)
        components(components == notComponents(i)) = 0;
		fprintf('Pruning component %d', i);
    end
    
    % Clean components, bboxes, compFeatures
    % Re-hashing the components with appropriate indices
    compIds = unique(components(:));
    newBboxes = zeros(length(compIds) - 1, 4); % Ignoring the zero unique value
    newCompFeat = {};
    compProbs = zeros(length(compIds)- 1, 1);
    
    % Scrapping zero
    compIds(compIds == 0) = [];
    
    % Re-hashing the components and information appropriately
    for i = 1:length(compIds)
        components(components == compIds(i)) = i;
        newBboxes(i, :) = newBboxes(compIds(i), :);
        newCompFeat = [newCompFeat, compFeat{compIds(i)}];
        compProbs(i) = probTest(compIds(i), 2);
    end
    
    bboxes = newBboxes;
    compFeat = newCompFeat;
end
