function chainFeat = evaluateChainFeatures(image, components,...
                                           chains, compFeat,...
                                           compProbabilities, angles)
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
    %       angles: 2D array containing the included angle for each pair of
    %           components.
    %
    % Output:
    %       % Will be filled later.
    
    chainFeat = {};
    
    % Run the iteration for each chain
    for idx=1:1:numel(chains)
        chain = chains{idx};
        
        % Number of candidates per chain.
        chainFeatStruct.nComp = length(chain);
        
        % Average probability of the candidates belonging to the chain.
        chainFeatStruct.avgProbability = ...
            mean(compProbabilities(chain));

        % Average color self similarity of the chain.
        avgColorSimilarity = computerColorSelfSimilarity(image,...
                                    components, chain);
        chainFeatStruct.avgColorSimilarity = avgColorSimilarity;

        % Average structure self similarity of the chain.
        avgStructureSimilarity = computerStructuresimilarity(image,...
                                    compFeat, chain);
        chainFeatStruct.avgStructureSimilarity = avgStructureSimilarity;

        % Average turning angle and distance variation.
        distances = zeros(length(Chain) - 1);
        avgTurningAngle = 0;
        for cIdx=1:length(chain}-1
            angle = angles(chain(cIdx), chain(cIdx+1));
            avgTurningAngle = avgTurningAngle + angle;
            center1 = compFeat(chain(cIdx));
            center2 = compFeat(chain(cIdx+1));
            diff = center1 - center2;
            distances(cIdx) = hypot(diff(1), diff(2));
        end
        chainFeatStruct.avgTurningAngle = avgTurningAngle/(size(chain)-1);
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
