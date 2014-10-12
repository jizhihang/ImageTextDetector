function swt_image = swtransform(image)
    % Function to calculate the Stroke Width Transform of a given image.
    % The function is named swtransform to avoid confusion with SWT,
    % stationary wavelet coefficients. The idea behind this code can  be
    % found at 
    %     http://www.math.tau.ac.il/~turkel/imagepapers/text_detection.pdf
    
    % Get the gray scale image
    imgray = rgb2gray(image);
    
    swt_image = inf(size(imgray));
    
    % Get the canny output for the image
    imedge = edge(imgray, 'canny'); % Let it choose the thresholds as of now.
   
    % edge does not return the gradient map. So get one.
    [gx gy] = gradient(double(imgray));
    imgrad = atan2(gy, gx);
    
    % We need gradient values at edge pixels only. Mask other values out.
    imgrad = imgrad.*imedge;
    
    % Get the indices where edges exist
    [xindices, yindices] = find(imedge == 1);
    
    % First pass. Iterate through all edge pixels.
    for idx = length(xindices)
        current_point = [xindices(idx), yindices(idx)];
        % Get the gradient at this point
        angle = imgrad(xindices(idx), yindices(idx));
        % Construct a ray on which we will traverse to find the "opposite"
        % pixel. Limit ourselves to at most 100 pixels.
        disp(angle)
        [ray_x, ray_y] = bresenhamLine(current_point, angle, 100);
        
        % Get the equivalent linear indices.
        ray_idx = sub2ind(size(imgray), ray_x, ray_y);
        
        % Find the ray indices which are on the edge.
        ray_edge_idx = ray_idx(imedge(ray_idx) == 1);
        
        % Get the X and Y indices.
        [x, y] = ind2sub(size(imgray), ray_edge_idx);
        
        % Find the nearest edge pixel
        [~, nearest_idx] = min(hypot(x-current_point(1), y-current_point(2)));
        xnear = x(nearest_idx);
        ynear = y(nearest_idx);
        
        % We are only tolerant of 30 degrees error.
        if abs(angle + imgrad(xnear, ynear)) < pi/6
            % SWT value is the distance between the two points.
            swt_value = hypot(current_point(1) - xnear, current_point(2) - ynear);
            [ray_mod_x, ray_mod_y] = bresenhamLine(current_point, angle, swt_value);
            ray_mod_idx = sub2ind(size(imgray), ray_mod_x, ray_mod_y);
            % Assign the SWT value only if it is less than the current swt
            % value.
            swt_image(swt_image(ray_mod_idx) < swt_value) = swt_value;
        end
    end
    swt_image(swt_image == inf) = 0;
end