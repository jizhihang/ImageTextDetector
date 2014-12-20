function im = drawRect(im, dims, color)
    % DRAWRECT function to draw a rectangle on an image with given color
    %
    % Usage:
    % drawImage = drawRect(toDrawImage, dimensionVals, Color);
    % 
    % dims(1) - minRow
    % dims(2) - maxRow
    % dims(3) - minCol
    % dims(4) - maxCol

    % Transforming the dims into bb format; bb = [x1, y1, width, height];
	dims(1) = max(0, dims(1));
	dims(2) = min(size(im,1), dims(2));
	dims(3) = max(0, dims(3));
	dims(4) = min(size(im,2), dims(4));
    bb = [dims(3), dims(1), dims(4)-dims(3), dims(2)-dims(1)];

    assert (ismatrix(im) || (ndims(im) == 3 && size(im,3) == 3));
    assert (isvector(bb) && length(bb) == 4);
    %assert (bb(1) >= 1 && bb(1)+bb(3) < size(im,2));
    %assert (bb(2) >= 1 && bb(2)+bb(4) < size(im,1));

    if ismatrix(im); nCh = 1; else nCh = 3; end
    for c = 1 : nCh
        im (bb(2) : bb(2)+bb(4)-1, bb(1), c)         = color(c);
        im (bb(2) : bb(2)+bb(4)-1, bb(1)+bb(3)-1, c) = color(c);
        im (bb(2), bb(1) : bb(1)+bb(3)-1, c)         = color(c);
        im (bb(2)+bb(4)-1, bb(1) : bb(1)+bb(3)-1, c) = color(c);
    end
end
