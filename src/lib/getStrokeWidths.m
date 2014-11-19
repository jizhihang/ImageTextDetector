function[strokeWidthImg] = getStrokeWidths(imgrad, imedge, positive)
    % Function to get the stroke widths of a given edge image along/away from gradient
    % 
    % Usage:
    % strokeImg = getStrokeWidth(imgrad, xindices, yindices, positive)
    %
    % Input:
    % imgrad - Gradient of the image
    % imedge - Edges of the image (canny, sobel, etc)
    % positive - boolean value to indicate the direction of movement (along gradient if true, opposite if false)
    % 
    % Output : 
    % strokeWidthImg - The stroke width of the image evaluated at (xIndices, yIndices)

    % Get the indices where edges exist
    % Find returns (rowIndex, colIndex) which infact is (y, x) for co-ordinate geometry
    [yindices, xindices] = find(imedge == 1);
   
    maxStrokeWidth = 200;
    imSize = size(imgrad);
    swt_image = inf(imSize);

    %Setting the direction
    if(positive)
        direction = 1;
    else
        direction = 2;
    end

    % Index of non-discarded rays - storing the (x, y) along with swt value obtained
    % Size pre-assigned for speed; keeping track of no of rays becomes necessary
    successRays = zeros(length(xindices), 3);
    noRays = 0;

    % First pass. Iterate through all edge pixels.
    for idx = 1:length(xindices)
        current_point = [xindices(idx), yindices(idx)];
        % Get the gradient at this point
        angle = imgrad(yindices(idx), xindices(idx));
        % Construct a ray on which we will traverse to find the "opposite"
        % pixel. Limit ourselves to at most maxStrokeWidth pixels.
        %disp(angle)
        [ray_x, ray_y] = bresenhamLine(current_point, angle, maxStrokeWidth);
        % Removing the first entry that is the current itself
        % Choosing the indices based on the direction to traverse
        ray_x = ray_x(direction, 2:end);
        ray_y = ray_y(direction, 2:end);

        %Checking the extremes for the image boundary overshoots
        %ray_x = bsxfun(@max, ray_x, 1);
        %ray_x = bsxfun(@min, ray_x, size(imgrad, 2));
        %ray_y = bsxfun(@max, ray_y, 1);
        %ray_y = bsxfun(@min, ray_y, size(imgrad, 1));

        %Checking for extremes and trimming the ray accordingly
        % Four possibilities for four sides of the image
        rightExt = min(find(ray_x > imSize(2)));

        % Right boundary is not violated, now check for left boundary
        if(isempty(rightExt))
            leftExt = min(find( ray_x < 1 ));
            % Left boundary is violated
            if(~isempty(leftExt))
                xBound = leftExt;
            else
                xBound = length(ray_x) + 1;
            end
        else
            xBound = rightExt;
        end

        bottomExt = min(find(ray_y > imSize(1)));
        % Bottom boundary is not violated, now check for top boundary
        if(isempty(bottomExt))
            topExt = min(find( ray_y < 1 ));
            % Top boundary is also not violated
            if(~isempty(topExt))
                yBound = topExt;
            else
                yBound = length(ray_y) + 1;
            end
        else
            yBound = bottomExt;
        end
       
        extremeInd = min(xBound, yBound);

        %Debugging
        %fprintf('Size : (%d %d) Bounds : (%d %d) => %d\n', length(ray_x), length(ray_y), xBound, yBound, extremeInd);

        %Trimming the ray_y and ray_x accordingly
        ray_y = ray_y(1:extremeInd-1);
        ray_x = ray_x(1:extremeInd-1);
        
        % Get the equivalent linear indices.
        % Traversing in one direction (positive gradient for now)
        ray_idx = sub2ind(imSize, ray_y, ray_x);
        
        % Find the ray indices which are on the edge.
        ray_edge_idx = ray_idx(imedge(ray_idx) == 1);
        
        % Get the X and Y indices.
        [y, x] = ind2sub(imSize, ray_edge_idx);
        
        % Find the nearest edge pixel
        [~, nearest_idx] = min(hypot(x-current_point(1), y-current_point(2)));
        xnear = x(nearest_idx);
        ynear = y(nearest_idx);
        
        % We are only tolerant of 30 degrees error.
        %if 1
        if abs(angle - (pi + imgrad(ynear, xnear))) < pi/6 | ...
            abs(angle - (-pi + imgrad(ynear, xnear))) < pi/6
            % SWT value is the distance between the two points.
            swt_value = hypot(current_point(1) - xnear, current_point(2) - ynear);

            % Obtaining the trimmed ray, according to the swt width
            %Using bresenhamLine again, trying to re-use the already calculated value instead
            [ray_mod_x, ray_mod_y] = bresenhamLine(current_point, angle, swt_value);
            
            ray_mod_idx = sub2ind(imSize, ray_mod_y(direction, :), ray_mod_x(direction, :));
            % Assign the SWT value only if it is less than the current swt
            % value.
            swt_image(ray_mod_idx(swt_image(ray_mod_idx) > swt_value)) = swt_value;
            
            % Storing the successful / non-discarded ray
            successRays(noRays + 1, :) = [current_point(1), current_point(2), swt_value];
            noRays = noRays + 1;
        end
    end
    
    % Replacing infs with more- realistic value
    swt_image(swt_image == inf) = maxStrokeWidth;

    % In order to handle corner pixels, we revisit the non-discarded rays and calculate the median
    for rayId = 1:noRays
        xInd = successRays(rayId, 1);
        yInd = successRays(rayId, 2);
        angle = imgrad(yInd, xInd);

        % Generating the bresenhamLine for the given non-discarded ray
        [ray_x, ray_y] = bresenhamLine([xInd, yInd], angle, swt_image(yInd, xInd));

        % Getting the median and re-setting all the value to the median, if found greater
        rayIndices = sub2ind(imSize, ray_y(direction, :), ray_x(direction, :));
        medianWidth = median(swt_image(rayIndices));

        % For all the points on the ray where swt value is greater than the median, replaec it with the median
        swt_image(rayIndices(swt_image(rayIndices) > medianWidth)) = medianWidth;
    end

    strokeWidthImg = swt_image;
end
