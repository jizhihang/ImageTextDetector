function[similarity] = computeChainSimilarity(chain1, chain2, compCharacteristics, omega)
    % Function to evaluate the orientation and population similarity between two chains 
    % 
    % Usage: 
    % similarity = computeChainSimilarity(chain1, chain2, compCharacteristics)
    %
    % Input:
    % Two chains, chain1 and chain2 which are list of components
    % comprCharacteristics = List of all characteristics of components from which 
    %                       current chain components can be read off
    % Omega = Weighting factor for orientation similarity
    %
    % similarity = Similarity between the two chains

    % Computing the average orientation of two chains
    meanChain1 = 0;
    for i = 1:length(chain1)
        meanChain1 = meanChain1 + compCharacteristics{chain1(i)}.direction;
    end
    meanChain1 = meanChain1 / length(chain1);

    meanChain2 = 0;
    for i = 1:length(chain2)
        meanChain2 = meanChain2 + compCharacteristics{chain2(i)}.direction;
    end
    meanChain2 = meanChain2 / length(chain2);

    % Computing the orientation similarity and population similarity
    % Returning the final weighted similarity
    angleDiff = abs(meanChain1 - meanChain2);
    if(angleDiff < pi/8)
        orientSim = 1 - angleDiff / (pi/2);
        popSim = 1 - abs(length(chain1) - length(chain2)) / (length(chain1) + length(chain2)); 
    else
        orientSim = 0;
        popSim = 0;
    end

    similarity = orientSim * omega + (1-omega) * popSim;
end
