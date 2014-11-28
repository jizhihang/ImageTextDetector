function[meanSimilarity] = computeColorSelfSimilarity(image, components, chain)
    % Function to compute the self similarity based on local descriptor
    % For now implemented as a cosine similarity between three channels with 10 bins    % for each channel giving a 30 dimensional vector
    %
    % Usage :
    % selfSimImg = computeColorSelfSimilarity(image, components, chain)
    %
    % Input:
    % image = Color (RGB/Lab) image for which color self similarity is to be computed
    % components = Points belonging to image indexed by the component Id
    % chains = List of chains for which color self similarity is to be computed
    %           Each chain is a list of components
    %
    % Output : 
    % meanSimilarity = mean similarity of all the pair of components for a chain

    % Dividing 0-255 into 10 equal histgrams
    noBins = 10;
    histExt = linspace(0, 255 , noBins+1);
    histCenters = (histExt(1:end-1) + histExt(2:end)) * 0.5;

    noComps = length(chain);
    featureVectors = zeros(noComps, 3 * noBins);
    % Get color self similarity feature for each component
    for i = 1:noComps
        compMembers = find(components == chain(i));
        disp(size(components));
        % For each channel
        for j = 1:3
            imageChannel = image(:,:,j);
            channel = imageChannel(compMembers);
            histogram = hist(channel(:), histCenters);
            indices = (j-1)*noBins+1:j*noBins;
            featureVectors(i, indices) = histogram;
        end

        % Normalizing by the number of members in the component
        featureVectors(i, :) = featureVectors(i, :) / length(compMembers);

        % Normalizing to make them unit norm vectors for dot product similarity
        featureVectors(i, :) = featureVectors(i, :) / norm(featureVectors(i,:));
    end

    % Get the mean of all the cosine similarity between the pairs of components
    meanSimilarity = zeros(noComps * (noComps-1) * 0.5, 1);
    count = 1;
    for i = 1:noComps-1
        for j = i+1:noComps
            meanSimilarity(count) = sum(featureVectors(i, :) .* featureVectors(j, :));
            count = count + 1;
        end
    end
    
    meanSimilarity = mean(meanSimilarity);
end
