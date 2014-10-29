function swt_image = swtransform(image)
    % Function to calculate the Stroke Width Transform of a given image.
    % The function is named swtransform to avoid confusion with SWT,
    % stationary wavelet coefficients. The idea behind this code can  be
    % found at 
    %     http://www.math.tau.ac.il/~turkel/imagepapers/text_detection.pdf
    %
    % Usage : swtImage = swtransform(image)
    % image = RGB image on which Stroke Width Transformation is to be applied
    %
    % Output:
    % swtImage = Matrix, with same dimensions as images, with estimated stroke width at each point
    
    % Get the gray scale image
    imgray = rgb2gray(image);
    
    % Get the canny output for the image
    imedge = edge(imgray, 'canny'); % Let it choose the thresholds as of now.
   
    % edge does not return the gradient map. So get one.
    [gx, gy] = derivative5(double(imgray), 'x', 'y');
    imgrad =  atan2(gy, gx);

    % We need gradient values at edge pixels only. Mask other values out.
    %imgrad = imgrad.*imedge;
    
    % Computing the stroke widths along the positive direction of the gradient
    positive = true;
    swt_image = getStrokeWidths(imgrad, imedge, positive);
    %figure; imagesc(swt_image)

    % Computing the stroke widths along the negative direction of the gradient
    %positive = false;
    %swt_image = getStrokeWidths(imgrad, imedge, positive);
    %figure; imagesc(swt_image)
end
