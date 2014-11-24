function ssim = getStructureSimilarity(compFeat)
    % Function to calculate the cosine similarity between all pairs of
    % components.
    %
    % Input:
    %       compFeat: Cell of structs containing component level features.
    % Output:
    %       ssim: 2D array containing the cosine similarity of edge shape
    %           descriptors of each pair of components.
    
    ssim = zeros(numel(compFeat), numel(compFeat));
    
    for idx=1:numel(compFeat)
        for iidx = idx:numel(compFeat)
            edgeShape1 = compFeat{idx}.edgeShape;
            edgeShape2 = compFeat{iidx}.edgeShape;
            cosine_similarity = ...
                sum(edgeShape1.*edgeShape2)/...
                (norm(edgeShape1)*norm(edgeShape2));
            ssim(idx, iidx) = cosine_similarity;
            ssim(iidx, idx) = cosine_similarity;
        end
    end
end