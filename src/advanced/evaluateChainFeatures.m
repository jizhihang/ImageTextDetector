function chainFeat = evaluateChainFeatures(chains, compFeat,...
                                           compProbabilities, angles,...
                                           colorSimilarity, ...
                                           structureSimilarity)
    % Function to evaluate the chain level features of an image. Function
    % returns an Array of struct containing the features of each chain
    % which will be used for training a random forest classifier in the
    % training phase and used for pruning non-word chains in the testing
    % phase.
    %
    % Inputs:
    %       chains: Struct of 1-D arrays containing the components which
    %           belong to a chain.
    %       compFeat: See evaluateComponentFeatures.
    %       compProbabilities: Probability of each component of it
    %           belonging to a text word. This is obtained from the random
    %           forest classifier at the component level.
    %       angles: 2D array containing the included angle for each pair of
    %           components.
    %       colorSimilarity: 2D array containing color similarity for each
    %           pair of components.
    %       structureSimilarity: 2D array containing structure similarity
    %       for each pair of components.
    %
    % Output:
    %       % Will be filled later.
    
    chainFeat = {};
    
    % Run the iteration for each chain
    for idx=1:1:numel(chains)
        chain = chains{idx};
        
        % Number of candidates per chain.
        chainFeatStruct.nComp = size(chain});
        
        % Average probability of the candidates belonging to the chain.
        chainFeatStruct.avgProbability = ...
            mean(compProbabilities(chain));
        
        % Average turning angle and distance variation.
        distances = zeros(length(Chain) - 1);
        avgTurningAngle = 0;
        avgColorSimilarity = 0;
        avgStructureSimilarity = 0;
        for cIdx=1:length(chain}-1
            angle = angles(chain(cIdx), chain(cIdx+1));
            cSim = colorSimilarity(chain(cIdx), chain(cIdx+1));
            sSim = structureSimilarity(chain(cIdx), chain(cIdx+1));
            avgColorSimilarity = avgColorSimilarity + cSim;
            avgStructureSimilarity = avgStructureSimilarity + sSim;
            avgTurningAngle = avgTurningAngle + angle;
            center1 = compFeat(chain(cIdx));
            center2 = compFeat(chain(cIdx+1));
            diff = center1 - center2;
            distances(cIdx) = hypot(diff(1), diff(2));
        end
        chainFeatStruct.avgTurningAngle = avgTurningAngle/(size(chain)-1);
        chainFeatStruct.avgColorSimilarity = ...
            avgColorSimilarity/(size(chain)-1);
        chainFeatStruct.avgStructureSimilarity = ...
            avgStructureSimilarity/(size(chain)-1);
        chainFeatStruct.distVariation = var(distances);
        
        % Size, axialratio, density, width variation and directions.
        sizes = zeros(length(chain));
        directions = zeros(length(chain));
        avgAxialRatio = 0;
        avgDensity = 0;
        avgWidthVariation = 0;
        for cIdx = 1:length(chain)
            sizes(cIdx) = compFeat{cIdx}.size;
            avgAxialRatio = avgAxialRatio + compFeat{cIdx}.AxialRatio;
            avgDensity = avgDensity + compFeat{cIdx}.density;
            avgWidthVariation = avgWidthVariation + ...
                compFeat{cIdx}.widthVariation;
            directions(cIdx) = compFeat{cIdx}.direction;
        end
        chainFeatStruct.sizeVariation = var(sizes);
        chainFeatStruct.directionBias = var(directions);
        chainFeatStruct.avgAxialRatio = avgAxialRatio/length(chain);
        chainFeatStruct.avgDensity = avgDensity/length(chain);
        chainFeatStruct.avgWidthVariation = avgWidthVariation/length(chain);
    end
end
