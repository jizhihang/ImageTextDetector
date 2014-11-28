function[members, clusterImg] = clusterIntoChains(compFeatures, components)
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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Threshold for color
    colorThreshold = 5.0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
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
            ratio = compFeatures{i}.meanWidth / compFeatures{j}.meanWidth;
            if(ratio > 2 || ratio < 0.5)
                continue;
            end

            % Ratio of characteristic radius is within 2.5
            ratio = compFeatures{i}.radius / compFeatures{j}.radius;
            if(ratio < 0.4 || ratio > 2.5)
                continue;
            end

            % Distance between them is less than 2 times the sum of characteristic scale
            distance = norm(compFeatures{i}.center - compFeatures{j}.center);
            if(distance > 2 * (compFeatures{i}.radius + compFeatures{j}.radius))
                continue;
            end

            % If colors are similar
            distance = norm(compFeatures{i}.meanColor - compFeatures{j}.meanColor);
            if(distance > colorThreshold)
                continue;
            end

            % Adding them as pairs
            members{noMembers + 1} = uint16([i, j]);
            noMembers = noMembers + 1;
        end
    end

    % Initializing the similarity matrix, checking for component having same element
    similarity = zeros(noMembers, noMembers);
    for i = 1:noMembers-1
        for j = i+1:noMembers
            if(~isempty(intersect(members{i}, members{j})))
                simVal = computeChainSimilarity(members{i}, members{j}, compFeatures, 0.5); 
                similarity(i, j) = simVal;
                similarity(j, i) = simVal;
            end
        end
    end

    noIters = 2;
    % Previously merged components
    mergedComps = [];
    % For the current iteration of clustering
    while(1)
        % Finding the pair with maximum similarity
        triMatrix = triu(similarity);
        [maxVal, maxIndex] = max(triMatrix(:));
        [chain1, chain2] = ind2sub(size(similarity), maxIndex);

        % Stop iterations if max similarity is less than a threshold
        if(maxVal < 0.1)
            maxVal
            break;
        end

        % Merging these two chains
        fprintf('Merging two chains : %d %d (sim: %f)\n', chain1, chain2, maxVal);
        mergedComps = [chain1, chain2];

        % Removing them from similarity matrix; clubbing them as last element; computing new similarities
        maxIndChain = max(chain1, chain2);
        minIndChain = min(chain1, chain2);
        similarity(:, maxIndChain) = [];
        similarity(:, minIndChain) = [];
        similarity(maxIndChain, :) = [];
        similarity(minIndChain, :) = [];

        newChain = union(members{chain1}, members{chain2});
        members{maxIndChain} = {};
        members{minIndChain} = {};
        members = members(~cellfun('isempty', members));

        noMembers = length(members) + 1;
        members{noMembers} = newChain;

        % Finding similarity with remaining elements
        newSimVals = zeros(size(similarity, 1), 1);
        for j = 1:size(similarity, 1)
            if(~isempty(intersect(newChain, members{j})))
                simVal = computeChainSimilarity(newChain, members{j}, compFeatures, 0.5); 
                newSimVals(j) = simVal;
            end
        end

        % Updating similarity matrix
        similarity = [[similarity; newSimVals'], [newSimVals; 0]];
    end

    % Visualizing the clusters
    clusterImg = zeros(size(components));
    for i = 1:length(members)
        for j = 1:length(members{i})
            clusterImg(components == members{i}(j))  = i;
        end
    end
end
