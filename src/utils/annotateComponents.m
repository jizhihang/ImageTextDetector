function annotatedImage = annotateComponents(im, components)
    % Function to annotate tne components and see various features. The
    % features include:
    % 1. Bounding boxes of components
    % 2. Centers of bounding boxes of components
    % 3. Mean L,a,b of each component.
    
    maxId = max(components(:));
    annotatedImageR = zeros(size(im, 1), size(im,  2));
    annotatedImageG = zeros(size(im, 1), size(im,  2));
    annotatedImageB = zeros(size(im, 1), size(im,  2));
    [L, a, b] = RGB2Lab(im);
    L = L*255.0/max(L(:));
    a = a*255.0/max(a(:));
    b = b*255.0/max(b(:));
    
    for idx=1:1:maxId;
        component_idx = find(components == idx);
        [x, y] = ind2sub(size(components), component_idx);
        
        % Fill the component with average Lab
        annotatedImageR(component_idx) = mean(L(component_idx));
        annotatedImageG(component_idx) = mean(a(component_idx));
        annotatedImageB(component_idx) = mean(b(component_idx));
        
        % Get the center of the component
        centerX = round(mean(x)); centerY = round(mean(y));
        % Draw a plus there.
        xmin = max(1, centerX-3);
        xmax = min(size(im,1), centerX+3);
        ymin = max(1, centerY-3);
        ymax = min(size(im,2), centerY+3);
        annotatedImageR(xmin:xmax, centerY) = 255;
        annotatedImageG(xmin:xmax, centerY) = 255;
        annotatedImageB(xmin:xmax, centerY) = 255;
        annotatedImageR(centerX, ymin:ymax) = 255;
        annotatedImageG(centerX, ymin:ymax) = 255;
        annotatedImageB(centerX, ymin:ymax) = 255;
        
        % Get the bounding box coordinates.
        minX = min(x); maxX = max(x);
        minY = min(y); maxY = max(y);
        % Draw a rectangle now.
        annotatedImageR = drawRect(annotatedImageR, ...
                                  [minX, maxX-1, minY, maxY-1], ...
                                  255);
        annotatedImageG = drawRect(annotatedImageG, ...
                                  [minX, maxX-1, minY, maxY-1], ...
                                  255);
        annotatedImageB = drawRect(annotatedImageB, ...
                                  [minX, maxX-1, minY, maxY-1], ...
                                  255);
    end
    annotatedImage = zeros(size(im));
    annotatedImage(:,:,1) = annotatedImageR;
    annotatedImage(:,:,2) = annotatedImageG;
    annotatedImage(:,:,3) = annotatedImageB;
end