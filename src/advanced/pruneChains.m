function[members, clusterImg] = pruneChains(image, components, members, compFeat,...
                            compProbs, chainModel)
    % Function to prune the chains using random forest classifier
    %
    % Usage:
    % [members] = pruneChains(image, components, members, compFeat,...
    %                        compProbs, chainModel)
    %
    % Input:
    % image = RGB image
    % components = Image that indicates Membership of all the pixels wrt
    %               components
    % members = clustered chains
    % compFeat = Features of the components that form the members of the
    %               chains
    % compProbs = Probabilities that each of the component is classified
    % chainModel = Random forest for the chain
    %
    % Output:
    % members = Cleaned up members of the chain for final text prediction
    % clusterImg = Image to visualize the grouping
    %

    % Evaluate features for existing chain
    [~, Xtest] = evaluateChainFeatures(image, components, members, compFeat, compProbs);
    
    % Classify whether its a chain or not; discard the negatively
    % classified chains
    Ytest = chainModel.predict(Xtest);
    
    notChains = find(cell2mat(Ytest) == 0);
    for i = 1:length(notChains)
        members{notChains{i}} = {}; 
    end
    
    % Cleaning the members cell
    % Return the remainder chains
    members = members(~cellfun('isempty', members));
    
    % Visualizing the cluster image
    
    % Visualizing the clusters
    clusterImg = zeros(size(components));
    for i = 1:length(members)
        for j = 1:length(members{i})
            disp(i);
            clusterImg(components == members{i}(j))  = i;
        end
    end
end