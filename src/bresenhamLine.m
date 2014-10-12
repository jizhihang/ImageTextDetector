function [x_indices, y_indices] = bresenhamLine(starting_point, angle, max_dist)
    % Function to calculate the indices lying on a line, the coordinates of
    % which are decided by the starting point and the slope.
    
    slope = tan(angle);
    
    % We have two cases. If slope is less than 1, then, every x coordinate
    % is unique. If slope is greater than 1, every y coordinate is unique.
    
    % Construct on one side. Mirror it to get the two sided ray.
    if slope < 1
        % Unique x indices.
        x_indices = starting_point(1):1:round(cos(angle)*max_dist);
        
        % Line equation: (y-y1) = m*(x-x1) => y = y1 + m*(x-x1)
        y_indices = starting_point(2) + slope*(x_indices - starting_point(1));
        
        % Find the nearest integer pixel. Simple use the round function.
        y_indices = round(y_indices);        
    else
        % Unique y indices.
        y_indices = starting_point(2):1:round(sin(angle)*max_dist);
        
        % Line equation: (y-y1) = m*(x-x1) => x = x1 + (1/m)*(y-y1)
        x_indices = starting_point(1) + (1/slope)*(y_indices - starting_point(2));
        
        % Find the nearest integer pixel. Simple use the round function.
        x_indices = round(x_indices);        
    end
    % Now mirror the indices
    y_indices = [-y_indices(end-1:-1:1), y_indices];
    x_indices = [-x_indices(end-1:-1:1), x_indices];
end
