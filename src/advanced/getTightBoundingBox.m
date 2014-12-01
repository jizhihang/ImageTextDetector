function bboxes = getTightBoundingBox(chains, components, compFeat)
    % Function to find the tightest bounding bounding boxes for each chain.
    % Details to be added later.
    
    nChains = numel(chains);
    bboxes = zeros(nChains, 5);
    
    % Iterate over each chain.
    for cIdx = 1:nChains
        % Get all the centers.
        chain = chains{cIdx};
        x = zeros(length(chain),1); y = zeros(length(chain),1);
        for mIdx = 1:length(chain)
            component = compFeat{chain(mIdx)};
            center = component.center;
            x(mIdx) = center(1); y(mIdx) = center(2);
        end
        % Do a linear fit to get the slop.
        P = polyfit(x, y, 1);
        % Slope is our direction of the bounding box.
        m = P(1);
        theta = atan(m);
        % Rotate the image to get the top left point and the height and
        % width.
        cRotated = imrotate(components, -theta*180/pi);
        
        % Getting the co-ordinates of the points belonging to the current
        % cluster by iterating over the components of cluster
        cX = []; cY = [];
        for compIdx = 1:length(chains{cIdx})
            [memberX, memberY] = find(components == chains{cIdx}(compIdx)); 
            cX = [cX; memberX]; 
            cY = [cY; memberY];
        end
        %[cX, cY] = find(components == cIdx);
        
        xMin = min(cX); xMax = max(cX);
        yMin = min(cY); yMax = max(cY);
        % Got everything.
        bboxes(cIdx, 1:end) = [xMin, yMin, xMax-xMin, yMax-yMin, theta];
    end
end