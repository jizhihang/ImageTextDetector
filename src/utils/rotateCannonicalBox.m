function [ corners ] = rotateCannonicalBox( cannonBox )
    % Rotates the cannonical box to get the four vertices of the arbitrary
    % oriented box
    %
    % Usage: 
    % corners = rotateCannonicalBox(cannonBox);
    %
    % Input :
    % CannonBox = Cannonical box
    % 
    % Output:
    % corners = Four corners of the rotated box
    % [corners.topLeft; corners.topRight; corners.bottomLeft;
    % corners.bottomRight]
    
    % Angle of rotation
    angle =  -1 * cannonBox(5);
    % Rotation matrix
    R = [cos(angle), sin(angle); -sin(angle), cos(angle)];

    % Calculating the center point for rotation about it
    centerPt = cannonBox(1:2) + 0.5 * cannonBox(3:4);
    shifts = 0.5 * cannonBox(3:4);
    
    % Getting four corners of the rotated box
    corners = [[-1, 1] .* shifts; [1, 1] .* shifts; ...
               [1 -1] .* shifts; [-1 -1].*shifts];  

    % Rotating the corners and translate to the center
    corners = bsxfun(@plus, (R * corners')',  centerPt);
end

