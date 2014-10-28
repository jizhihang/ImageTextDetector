function components = connectedComponents(swtimage, nbr_ratio)
    % Function to find the connected components in the stroke width
    % transformed image. Unlike the regular connected components analysis,
    % the criterion for adding a new pixel to an existing component is that
    % the SWT value of the new pixel should be within 3.0 times the current
    % pixel's SWT value. This gives a little flexibilty when dealing with
    % images of varied stroke width and distortion of image due to
    % perspective.
    %
    % Input:
    %       swtimage: Stroke Width Transform of an image containing text.
    %       nbr_ratio: Ratio of current pixel's SWT value to the neighbor's
    %                  SWT value which can be considered for adding it to
    %                  the current component.
    % Output: 
    %       components: image of the same dimension as "swtimage"
    %                   which contains the separated components.
    
    % Create matrices to store components and information about visited
    % pixels.
    visited_pixels = zeros(size(swtimage));
    components = zeros(size(swtimage));
    current_component = 1;
    
    [xdim, ydim] = size(swtimage);
    
    % Initiate by labelling the first pixel as 1
    components(1, 1) = current_component;
    visited_pixels(1, 1) = -1;
    
    % Create a list to store the neighboring pixels
    valid_nbr_x = [1];
    valid_nbr_y = [1];
    
    iter = 1;
    while true
        % Check if we have an empty valid_nbr_x. If so, increment the
        % component count and start with a fresh pixel.
        fprintf('Component: %d; Iteration: %d\n', current_component, iter);
        iter = iter + 1;
        if isempty(valid_nbr_x)
            [xnew, ynew] = find(visited_pixels == 0);
            % If we don't find anything, we are done scanning.
            if isempty(xnew)
                break;
            end
            valid_nbr_x = xnew(1);
            valid_nbr_y = ynew(1);
            current_component = current_component + 1;
        end
        aux_x = []; aux_y = [];
        for idx=1:length(valid_nbr_x)
            % Find the 3x3 patch coordinates
            xmin = max(1, valid_nbr_x(idx)-1); 
            xmax = min(xdim, valid_nbr_x(idx)+1);
            ymin = max(1, valid_nbr_y(idx)-1); 
            ymax = min(ydim, valid_nbr_y(idx)+1);
            
            % Find where the swt value is within [1/3.0, 3.0];
            curr_swt = swtimage(valid_nbr_x(idx), valid_nbr_y(idx));
            [xidx, yidx] = find(swtimage(xmin:xmax, ymin:ymax)/curr_swt ...
                                                       >= 1/nbr_ratio & ...
                                swtimage(xmin:xmax, ymin:ymax)/curr_swt ...
                                                         <= nbr_ratio & ...
                                visited_pixels(xmin:xmax, ymin:ymax) == 0);
            % Add them to the set of indices to traverse.
            aux_x = [aux_x (xmin - 1 + xidx)'];
            aux_y = [aux_y (ymin - 1 + yidx)'];
            % We have visited this pixel now.
            visited_pixels(valid_nbr_x(idx), valid_nbr_y(idx)) = -1;
            visited_pixels(sub2ind(size(swtimage), xmin - 1 + xidx, ...
                                                   ymin - 1 + yidx)) = -1;
            components(valid_nbr_x(idx), valid_nbr_y(idx)) = ...
                                                    current_component;
        end
        % Get rid of the visited pixels.
        valid_nbr_x = aux_x;
        valid_nbr_y = aux_y;
    end
end