function [x_indices, y_indices] = bresenhamLine(starting_point, angle, max_dist)
    % Function to calculate the indices lying on a line, the coordinates of
    % which are decided by the starting point and the slope.
    %
    % Usage: [xPts yPts] = bresenhamLine(startingPoint, angleRadian, halfSegmentWidth)
    %
    % startPoint = [x y] co-orinates of the point around which a line segment is to be constructed
    % angleRadian = The direction of exploration in radians [-pi, pi]
    % halfSegmentWidth = Exploration width on either sides of starting point with starting point as center
    %
    % Outputs the x and y co-ordinates starting from center to each extremes on single row i.e.
    % Center -> Extreme along positive gradient xPts(1, :) yPts(1, :)
    % Center -> Extreme along negative gradient xPts(2, :) yPts(2, :)
    % 
    % Eq: [x y] = bresenhamLine([4 1], pi/4, 5);
    
    slope = tan(angle);
    
    % We have two cases. If slope is less than 1, then, every x coordinate
    % is unique. If slope is greater than 1, every y coordinate is unique.
    
    % Construct on one side. Mirror it to get the two sided ray.
    if slope < 1
        % Unique x indices.
        %Generating the line with start point as origin and later shifting the entire segment
        x_extreme = round(cos(angle) * max_dist);
        if(x_extreme > 0)
            x_indices = 0:1:round(cos(angle)*max_dist);
        else
            x_indices = 0:-1:round(cos(angle)*max_dist);
        end
            
        %x_indices = starting_point(1):1:round(cos(angle)*max_dist);
        
        % Line equation: (y-y1) = m*(x-x1) => y = y1 + m*(x-x1)
        % For origin : y = m * x 
        y_indices = slope * x_indices;
        %y_indices = starting_point(2) + slope*(x_indices - starting_point(1));
        
        % Find the nearest integer pixel. Simple use the round function.
        y_indices = round(y_indices);        
    else
        % Unique y indices.
        %Generating the line with start point as origin and later shifting the entire segment
        y_extreme = round(sin(angle) * max_dist);
        if(y_extreme > 0)
            y_indices = 0:1:round(sin(angle)*max_dist);
        else
            y_indices = 0:-1:round(sin(angle)*max_dist);
        end
        %y_indices = starting_point(2):1:round(sin(angle)*max_dist);
        
        % Line equation: (y-y1) = m*(x-x1) => x = x1 + (1/m)*(y-y1)
        % For origin : x = 1/m * y
        x_indices = (1/slope) * y_indices;
        
        % Find the nearest integer pixel. Simple use the round function.
        x_indices = round(x_indices);        
    end
    % Now mirror the indices to generate the required line centered at origin
    %y_indices = [-y_indices(end-1:-1:1), y_indices];
    %x_indices = [-x_indices(end-1:-1:1), x_indices];
    y_indices = starting_point(2) + [y_indices; -y_indices];
    x_indices = starting_point(1) + [x_indices; -x_indices];
end
