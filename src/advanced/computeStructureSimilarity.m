function avgSSIM = computeStructureSimilarity(image, compFeat, chain)
    % Function to evaluate the average structural self similarity of a given
    % chain of components.
    %
    % Input:
    %       image: Input image.
    %       compFeat: Cell of structs containing the component features.
    %       chain: A 1D array containing the IDs of components belonging to 
    %           the chain.
    %
    % Output:
    %       avgSSIM: Average SSIM of the given chain.

    avgSSIM = 0;
    nElements = 0;
    for idx=1:length(chain)
        for iidx=idx+1:length(chain)
            % Get the edge shapes.
            edgeShape1 = compFeat{idx}.edgeShape;
            edgeShape2 = compFeat{iidx}.edgeShape;
            crossProd = edgeShape1.*edgeShape2;
            selfProd1 = edgeShape1.*edgeShape1;
            selfProd2 = edgeShape2.*edgeShape2;
            SSIM = sum(crossProd)/(sqrt(sum(selfProd1))*sqrt(sum(selfProd2)));
            avgSSIM = avgSSIM + SSIM;
            nElements = nElements + 1;
        end
    end
    avgSSIM = avgSSIM/nElements;
end
