function compInfoStruct = getComponentInformation(compMap, chars,...
                                        gradContour, gradComp, swtComp, bbox)
    % Function to get the information for a single component.
    % More information will be added later.
    
    % Form a meshgrid of points.
    [xdim, ydim] = size(gradContour);
    
    % First template is simple, it is the circle formed by the
    % characteristic radius.
    [x, y] = meshgrid(1:xdim, 1:ydim);
    x = x - chars.relCenter(1); y = y - chars.relCenter(2);
    templatePoints = find(x.^2 + y.^2 <= chars.charRadius^2);
    
    % Get all the orientations and rotate it by characteristic orientation.
    contourOrientations = gradContour(templatePoints) + chars.orientation;
    edgeOrientations = gradComp(templatePoints) + chars.orientation;
    
    % Normalize to [0, pi]
    coMin = min(contourOrientations); coMax = max(contourOrientations);
    eoMin = min(edgeOrientations); eoMax = max(edgeOrientations);    
    contourOrientations = pi*(contourOrientations - coMin)/(coMax - coMin);
    edgeOrientations = pi*(edgeOrientations - eoMin)/(eoMax - eoMin);
    
    % Get six bin orientation.   
    edgeHist = hist(edgeOrientations, 6);
    contourHist = hist(contourOrientations, 6);
    
    contourShape = contourHist;
    edgeShape = edgeHist;
    templateMask = zeros(size(gradContour));
    templateMask(templatePoints) = 1;
    templateComponent = compMap.*templateMask;
    occupationRatio = sum(templateComponent(:))/(pi*chars.charRadius^2);
    
    % Now we need to evaluate in sectors.
    minRadii = [0 chars.charRadius/2];
    stepRadius = chars.charRadius/2;
    xr = x*cos(chars.orientation) - y*sin(chars.orientation);
    yr = x*sin(chars.orientation) + y*cos(chars.orientation);
    angleMap = pi + atan2(yr, xr);
    %imagesc(templateMask); pause();
    sectorAngles = [0 pi/2 pi 3*pi/2];
    
    for minRadius = minRadii
        for angle = sectorAngles
            dists = xr.^2 + yr.^2;
            validPoints = find( (dists > minRadius^2).*...
                                (dists <= (minRadius+stepRadius)^2).*...
                                (angleMap > angle).*...
                                (angleMap <= angle+pi/2) );
            contourOrientations = gradContour(validPoints) + chars.orientation;
            edgeOrientations = gradComp(validPoints) + chars.orientation;

            % Normalize to [0, pi]
            coMin = min(contourOrientations); coMax = max(contourOrientations);
            eoMin = min(edgeOrientations); eoMax = max(edgeOrientations);    
            contourOrientations = pi*(contourOrientations - coMin)/(coMax - coMin);
            edgeOrientations = pi*(edgeOrientations - eoMin)/(eoMax - eoMin);

            % Get six bin orientation.   
            edgeHist = hist(edgeOrientations, 6);
            contourHist = hist(contourOrientations, 6);
            
            % Occupation ratio
            templateMask = zeros(size(gradContour));
            templateMask(validPoints) = 1;
            templateComponent = compMap.*templateMask;
            if minRadius == 0
                occRatio = sum(templateComponent(:))/...
                               (0.0625*pi*chars.charRadius^2);
            else
                occRatio = sum(templateComponent(:))/...
                               (3*0.0625*pi*chars.charRadius^2);
            end
            % concatenate it.
            contourShape = [contourShape contourHist];
            edgeShape = [edgeShape edgeHist];
            occupationRatio = [occupationRatio occRatio];
        end
    end
    % Create a final struct.
    compInfoStruct.contourShape = contourShape;
    compInfoStruct.edgeShape = edgeShape;
    compInfoStruct.occupationRatio = occupationRatio;
    compInfoStruct.AxialRatio = chars.majorAxis/chars.minorAxis;
    compInfoStruct.widthVariation = mean(swtComp)/sqrt(var(swtComp));
    compInfoStruct.density = sum(compMap(:))/(pi*chars.charRadius^2);
    compInfoStruct.bbox = bbox;
    compInfoStruct.size = chars.charRadius;
    compInfoStruct.center = chars.barycenter;
    compInfoStruct.direction = chars.orientation;
end