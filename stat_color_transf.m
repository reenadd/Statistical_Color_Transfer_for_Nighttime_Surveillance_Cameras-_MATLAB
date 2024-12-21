

function [outputRGB, outputEq, med_output, sharp_output] = stat_color_transf(S, T)
    % Function to convert an RGB dark (low-light) image to a lighter, more visible one
    % Input: 
    %   S: the source, dark RGB image (3D matrix)
    %   T: the reference, normal-light RGB image (3D matrix)
    % Output:
    %   does not return any value, but performs multi-steps image processing
    %   to enhance the visibility of a dark RGB image


        % Step 1: convert images to LAB color space

    Slab = rgb2lab(S);
    Tlab = rgb2lab(T);

    % this operation converts the two images from RGB to LAB colorspace,
    % which is more suitable for processing


        % Step 2: perform statistical color transfer on each channel of S
    % This step utilizes the mean and std of the two images to perform a
    % statistic color transfer from the normal-light image to the low-light
    % one, hence improving its visibilty and clarity.

    output = zeros(size(S));


        % Process each LAB channel of the source image with its
        % corresponding one from the reference image
    for channel = 1:3

            % Calculating mean & standard deviation of both images' current
            % channel
        Simean = mean2(Slab(:,:,channel));
        Timean = mean2(Tlab(:,:,channel));

        Sistd = std2(Slab(:,:,channel));
        Tistd = std2(Tlab(:,:,channel));

            % Extract the current channel for processing
        Si = Slab(:,:,channel);

            % Performing statistical color transfer based on a predefined
            % equation
        output(:,:,channel) = (Tistd/Sistd)*(Si - Simean)+Timean;
    end



        % Step 3 Convert back to RGB


    outputRGB = lab2rgb(output);

    % this step converts the processed image back from LAB to RGB
    % colorspace for further processing.
    % the result of this step is a slightly, but not optimally lightened
    % image. Hence, more processing is required.
    

        % step 4: Choose between adapthisteq and histeq based on standard deviation to enhance contrast

    % Histogram equalization is necessary to further enhance the images'
    % colors and brighness. However, extremely low-brightness images need
    % the use of adaptive histogram equalization, whereas applying it to
    % somewhat bright images introduces noise that normal equalization does
    % not. So, after carrying out various experiments, we concluded that
    % the standard deviation of the first LAB channel's histogram is a good
    % representator of the image's brightness, and a threshold of 3.3*10^4
    % adequetly seperates the two conditions.


        % Determine the standard deviation of the image's histogram
 
    sdL = std(imhist(output(:,:,1)));

        % Define threshold
    stdthresh = (3.3)*10^4;

        % Apply adaptive or normal histogram equalization based on the
        % image brightness

    outputEq = zeros(size(outputRGB));
    if sdL > (stdthresh) 
        outputEq(:,:,1) = adapthisteq(outputRGB(:,:,1), 'ClipLimit',0.05,'Distribution','uniform');
        outputEq(:,:,2) = adapthisteq(outputRGB(:,:,2), 'ClipLimit',0.05,'Distribution','uniform');
        outputEq(:,:,3) = adapthisteq(outputRGB(:,:,3), 'ClipLimit',0.05,'Distribution','uniform');   
    else
        outputEq(:,:,1) = histeq(outputRGB(:,:,1));
        outputEq(:,:,2) = histeq(outputRGB(:,:,2));
        outputEq(:,:,3) = histeq(outputRGB(:,:,3));
    end

    % This result in an RGB image with better colors distributions and
    % brightness.



        % step 5: Apply median filtering to the enhanced image for denoising

    med_output = zeros(size(outputEq));
    for channel = 1:3
        med_output(:, :, channel) = medfilt2(outputEq(:, :, channel));
    end

    % This step removes any noise caused by previos processings while
    % keeping valuable details



        % Step 6: Sharpen the denoised image using unsharp masking
 
    sharp_output = zeros(size(med_output));
    h = fspecial('gaussian', [5 5], 1); % Create a Gaussian filter

    for channel = 1:3
        % Apply Gaussian filtering to create a blurred version of the image
        blurredImg = imfilter(med_output(:, :, channel), h, 'replicate');
    
        % Perform unsharp masking
        sharp_output(:, :, channel) = imadd(med_output(:, :, channel), ...
        imsubtract(med_output(:, :, channel), blurredImg));
    end

    % This effectively emphasizes the image's details and compensates well 
    % for the trade-off introduced by median filtering, hence emproving the
    % quality.

    
        % plotting results
    % figure,
    % subplot(2,2,1), imshow(S), title('original')
    % subplot(2,2,2), imshow(outputRGB), title('enhanced')
    % subplot(2,2,3), imshow(outputEq), title ('RGB equalized')
    % subplot(2,2,4), imshow(med_output), title('denoised')
    % sgtitle('results')

    figure,
    subplot(2,3,1), imshow(S), title('Original')
    subplot(2,3,2), imshow(T), title('Reference')
    subplot(2,3,3), imshow(outputRGB), title('Color Transfer')
    subplot(2,3,4), imshow(outputEq), title ('RGB Equalized')
    subplot(2,3,5), imshow(med_output), title('Median Filtering')
    subplot(2,3,6), imshow(sharp_output), title('Unsharp Masking')
    sgtitle('Images Results')

    figure,
    subplot(2,3,1), imhist(S), title('Original')
    subplot(2,3,2), imhist(T), title('Reference')
    subplot(2,3,3), imhist(outputRGB), title('Color Transfer')
    subplot(2,3,4), imhist(outputEq), title ('RGB Equalized')
    subplot(2,3,5), imhist(med_output), title('Median Filtering')
    subplot(2,3,6), imhist(sharp_output), title('Unsharp Masking')
    sgtitle('Histograms Results')


    % figure,
    % subplot(2,3,1), imhist(outputRGB(:,:,1)), title('enhanced red')
    % subplot(2,3,2), imhist(outputRGB(:,:,2)), title('enhanced green')
    % subplot(2,3,3), imhist(outputRGB(:,:,3)), title ('enhanced blue')
    % subplot(2,3,4), imhist(outputEq(:,:,1)), title('eq red')
    % subplot(2,3,5), imhist(outputEq(:,:,2)), title('eq green')
    % subplot(2,3,6), imhist(outputEq(:,:,3)), title('eq blue')
    % sgtitle('RGB histograms')



    % figure,
    % subplot(2,2,1), imhist(S), title('original histogram')
    % subplot(2,2,2), imhist(outputRGB), title('enhanced histogram')
    % subplot(2,2,3), imhist(outputEq), title('RGB equalized histogram')
    % subplot(2,2,4), imhist(med_output), title('denoised histogram')
    % sgtitle('results with histograms')

    figure,
    %subplot(2,2,1), imhist(S), title('original histogram')
    subplot(2,2,1), imhist(outputRGB), title('enhanced histogram')
    subplot(2,2,2), imhist(outputEq), title('RGB equalized histogram')
    subplot(2,2,3), imhist(med_output), title('denoised histogram')
    subplot(2,2,4), imhist(sharp_output), title('sharpened histogram')
    sgtitle('results with histograms')


end