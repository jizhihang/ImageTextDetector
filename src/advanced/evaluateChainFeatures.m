function chainFeat = evaluateChainFeatures(image, components,...
                                           chains, compFeat,...
                                           compProbabilities)
    % Function to evaluate the chain level features of an image. Function
    % returns an Array of struct containing the features of each chain
    % which will be used for training a random forest classifier in the
    % training phase and used for pruning non-word chains in the testing
    % phase.
    %
    % Inputs:
    %       image: Input image.
    %       components: 2D array of the same size as image which contains 
    %           component ID per each component.
    %       chains: Struct of 1-D arrays containing the component IDs which
    %           belong to a chain.
    %       compFeat: See evaluateComponentFeatures.
    %       compProbabilities: Probability of each component of it
    %           belonging to a text word. This is obtained from the random
    %           forest classifier at the component level.
    %
    % Output:
    %       % Will be filled later.
    
    chainFeat = {};
    
    % Run the iteration for each chain
    for idx=1:1:numel(chains)
        chain = chains{idx};

        % Sort the chain
        chain = sortChain(chain,compFeat);
        
        % Number of candidates per chain.
        chainFeatStruct.nComp = length(chain);
        
        % Average probability of the candidates belonging to the chain.
        chainFeatStruct.avgProbability = ...
            mean(compProbabilities(chain));

        % Average color self similarity of the chain.
        avgColorSimilarity = computeColorSelfSimilarity(image,...
                                    components, chain);
        chainFeatStruct.avgColorSimilarity = avgColorSimilarity;

        % Average structure self similarity of the chain.
        avgStructureSimilarity = computeStructureSimilarity(image,...
                                    compFeat, chain);
        chainFeatStruct.avgStructureSimilarity = avgStructureSimilarity;

        % Average turning angle and distance variation.
        distances = zeros(1, length(chain) - 1);
        avgTurningAngle = 0;
        for cIdx=1:length(chain)-1
            compFeat1 = compFeat{chain(cIdx)};
            compFeat2 = compFeat{chain(cIdx+1)};
            center1 = compFeat1.center;
            center2 = compFeat2.center;
            angle = atan2(center2(2)-center1(2), center2(1)-center1(1));
            avgTurningAngle = avgTurningAngle + angle;
            diff = center1 - center2;
            distances(cIdx) = hypot(diff(1), diff(2));
        end
        chainFeatStruct.avgTurningAngle = avgTurningAngle/(length(chain)-1);
        chainFeatStruct.distVariation = var(distances);
        
        % Size, axialratio, density, width variation and directions.
        sizes = zeros(1, length(chain));
        directions = zeros(1, length(chain));
        avgAxialRatio = 0;
        avgDensity = 0;
        avgWidthVariation = 0;
        for cIdx = 1:length(chain)
            sizes(cIdx) = compFeat{cIdx}.radius;
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
        chainFeat{idx} = chainFeatStruct;
    end
end
