function[] = clusterIntoChains(compFeatures)
    % Function to cluster chains hierarchically using distance measures corresponding to
    % orientation and population metrics
    %
    % Usage:
    % clusters = clusterIntoChains(compFeatures)
    %
    % Input:
    % compFeatures = The features of components used to merge them into chains
    %
    % Output:
    % clusters =  
    %
    
    % Initializing members for first iteration (members identified by id)
    % Members for the first iteration are pairs of components that are compatible
    noComps = length(compFeatures);
    members = cell(0, 1);

    % Count for number of members
    noMembers = 0;
    for i = 1:noComps-1
        for j = i+1:noComps
            % Checking if components can be clubbed into pairs
            
            % Ratio of stroke width means is less than 2


            % Ratio of characteristic radius is within 2.5


            % Distance between them is less than 2 times the sum of characteristic scale
            if()




            % Adding them as pairs
            members{noMembers + 1} = [i, j];
        end
    end

    noMembers = length(members);

    noIters = 1;
    % Previously merged components
    mergedComps = [];

    % Initializing the similarity matrix
    similarity = zeros(noMembers, noMembers);
    for i = 1:noMembers-1
        for j = i+1:noMembers
            simVal = computeChainSimilarity(members{i}, members{j}); 
            similarity(i, j) = simVal;
            similarity(j, i) = simVal;
        end
    end

    % For the current iteration of clustering
    for i = 1:noIters
        % Finding the pair with maximum similarity
        triMatrix = triu(similarity);
        [~, maxIndex] = max(triMatrix(:));
        [chain1, chain2] = ind2sub(maxIndex, size(similarity));

        newChain

        % Removing them from similarity matrix and computing new similarities
    
        % Number of members participating in merging
        noMembers = length(members);
      
        

        
    
    end




end
