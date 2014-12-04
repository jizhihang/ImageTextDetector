function drawImage = drawLine(drawImage, p1, p2, color)
	% Function to draw line between the two given points p1 and p2
	%
	% Input:
	%		drawImage: Image over which the the line needs to be drawn.
	%		p1: First point.
	%		p2: Second point.
	%		color: Color of the line.
	%
	% Output:
	%		drawImage: Output image with the drawn line.
	%

	[m, n, c] = size(drawImage);
	% Get the delta x and delta y
	dx = p2(1) - p1(1); dy = p2(2) - p1(2);

	% Get distance and angle
	max_dist = hypot(dx, dy);
	angle = atan2(dy, dx);

	% Get the indices from bresenham line
	[xIdx, yIdx] = bresenhamLine(p1, angle, max_dist);
	
	% t = find((xIdx > 0).*(xIdx < m));
	% xIdx = xIdx(t); yIdx = yIdx(t);
	% t = find((yIdx > 0).*(yIdx < n));
	% xIdx = xIdx(t); yIdx = yIdx(t);
	
	if c == 1
		% Get the linear indices.
		lineIdx = sub2ind(size(drawImage), xIdx(1, :), yIdx(1, :));

		% Draw the line.
		drawImage(lineIdx) = color;
	else
		imR = drawImage(:,:,1);
		imG = drawImage(:,:,2);
		imB = drawImage(:,:,3);

		lineIdx = sub2ind(size(imR), xIdx(1, :), yIdx(1,:));

		imR(lineIdx) = color(1);
		imG(lineIdx) = color(2);
		imB(lineIdx) = color(3);

		drawImage(:,:,1) = imR;
		drawImage(:,:,2) = imG;
		drawImage(:,:,3) = imB;
	end
end
