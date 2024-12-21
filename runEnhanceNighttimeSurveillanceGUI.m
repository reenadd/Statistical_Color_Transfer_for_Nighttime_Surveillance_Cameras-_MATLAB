function runEnhanceNighttimeSurveillanceGUI
    % This function initializes a GUI application for enhancing nighttime surveillance images
    % by allowing users to load a source image and a reference image, then processing 
    % them to enhance the source based on the reference image characteristics. 
    % The GUI includes options to display histograms and multiple stages of enhanced images.
    
    % Define the background color for the GUI elements
    bgColor = [0.88, 0.92, 0.95];

    % Create the main GUI window with specified properties for title, position, and color
    fig1 = figure('Name', 'Enhance Nighttime Surveillance - Input', 'Position', [100, 100, 800, 600], ...
                  'Units', 'pixels', 'Color', bgColor);

    % Add a main title at the top of the GUI window for clear identification
    uicontrol('Style', 'text', 'String', 'Enhance Nighttime Surveillance Application', ...
        'Units', 'normalized', 'Position', [0.1, 0.92, 0.8, 0.05], ...
        'BackgroundColor', bgColor, 'ForegroundColor', [0.2, 0.3, 0.4], ...
        'FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');

    % Create a panel to organize action buttons for loading images and processing them
    button_panel = uipanel('Position', [0.1, 0.85, 0.8, 0.08], ...
                           'Units', 'normalized', 'BackgroundColor', bgColor, 'BorderType', 'none');

    % Button for loading a source image from the user's file system
    uicontrol('Parent', button_panel, 'Style', 'pushbutton', 'String', 'Load Source Image', ...
        'Units', 'normalized', 'Position', [0.05, 0.1, 0.25, 0.8], 'Callback', @loadSourceImage, ...
        'BackgroundColor', [0.2, 0.6, 0.8], 'ForegroundColor', 'white', 'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Arial');

    % Button for loading a reference image, which will be used as a basis for enhancement
    uicontrol('Parent', button_panel, 'Style', 'pushbutton', 'String', 'Load Reference Image', ...
        'Units', 'normalized', 'Position', [0.375, 0.1, 0.25, 0.8], 'Callback', @loadReferenceImage, ...
        'BackgroundColor', [0.2, 0.6, 0.8], 'ForegroundColor', 'white', 'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Arial');

    % Button to initiate image processing once source and reference images are loaded
    uicontrol('Parent', button_panel, 'Style', 'pushbutton', 'String', 'Process Images', ...
        'Units', 'normalized', 'Position', [0.7, 0.1, 0.25, 0.8], 'Callback', @runColorTransfer, ...
        'BackgroundColor', [0.2, 0.6, 0.8], 'ForegroundColor', 'white', 'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Arial');

    % Create axes for displaying the source image and its grayscale histogram
    ax1 = axes('Parent', fig1, 'Position', [0.05, 0.45, 0.4, 0.35]);
    ax1_hist = axes('Parent', fig1, 'Position', [0.05, 0.15, 0.4, 0.25]);

    % Create axes for displaying the reference image and its grayscale histogram
    ax2 = axes('Parent', fig1, 'Position', [0.55, 0.45, 0.4, 0.35]);
    ax2_hist = axes('Parent', fig1, 'Position', [0.55, 0.15, 0.4, 0.25]);

    % Initialize variables to store the loaded images for later processing
    sourceImage = [];
    referenceImage = [];

    % Callback function to load and display the source image selected by the user
    function loadSourceImage(~, ~)
        % Open a file selection dialog for image file types (.jpg, .jpeg, .png)
        [file, path] = uigetfile({'.jpg;.jpeg;*.png', 'Image Files (.jpg, *.jpeg, *.png)'}, ...
            'Select Source Image');
        
        % Check if the user canceled the file selection
        if isequal(file, 0)
            disp('No source image selected');
            return;
        end

        % Load the selected image, display it, and plot its grayscale histogram
        sourceImage = imread(fullfile(path, file));
        imshow(sourceImage, 'Parent', ax1);
        title(ax1, 'Source Image');

        % Display grayscale histogram of the source image for visual analysis
        axes(ax1_hist);  % Set ax1_hist as the active axes
        imhist(rgb2gray(sourceImage));  % Display histogram
        title(ax1_hist, 'Source Histogram');
    end

    % Callback function to load and display the reference image selected by the user
    function loadReferenceImage(~, ~)
        % Open a file selection dialog for image file types (.jpg, .jpeg, .png)
        [file, path] = uigetfile({'.jpg;.jpeg;*.png', 'Image Files (.jpg, *.jpeg, *.png)'}, ...
            'Select Reference Image');

        % Check if the user canceled the file selection
        if isequal(file, 0)
            disp('No reference image selected');
            return;
        end

        % Load the selected reference image, display it, and plot its grayscale histogram
        referenceImage = imread(fullfile(path, file));
        imshow(referenceImage, 'Parent', ax2);
        title(ax2, 'Reference Image');

        % Display grayscale histogram of the reference image for visual analysis
        axes(ax2_hist);  % Set ax2_hist as the active axes
        imhist(rgb2gray(referenceImage));  % Display histogram
        title(ax2_hist, 'Reference Histogram');
    end

    % Callback function to process images through color transfer and enhancement
    function runColorTransfer(~, ~)
        if isempty(sourceImage) || isempty(referenceImage)
            % Alert user if source and reference images have not been loaded
            errordlg('Please load both source and reference images.', 'Error');
            return;
        end

        % Process images through color transfer, and apply enhancements such as histogram equalization
        [outputRGB, outputEq, med_output, sharp_output] = stat_color_transf(sourceImage, referenceImage);

        % Display the enhanced and equalized images in a new window with their histograms
        fig2 = figure('Name', 'Processed Images - Part 1', 'Position', [100, 100, 800, 600], ...
                      'Units', 'pixels', 'Color', bgColor);
        uicontrol('Style', 'text', 'String', 'Processed Images - Enhanced and Equalized', ...
            'Units', 'normalized', 'Position', [0.1, 0.92, 0.8, 0.05], ...
            'BackgroundColor', bgColor, 'ForegroundColor', [0.2, 0.3, 0.4], ...
            'FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');

        % Create axes for displaying enhanced and equalized images and their histograms
        ax3 = axes('Parent', fig2, 'Position', [0.1, 0.55, 0.35, 0.35]);
        ax3_hist = axes('Parent', fig2, 'Position', [0.1, 0.1, 0.35, 0.35]);
        ax4 = axes('Parent', fig2, 'Position', [0.55, 0.55, 0.35, 0.35]);
        ax4_hist = axes('Parent', fig2, 'Position', [0.55, 0.1, 0.35, 0.35]);

        % Show enhanced image, plot its grayscale histogram
        imshow(outputRGB, 'Parent', ax3);
        title(ax3, 'Enhanced');
        axes(ax3_hist);
        imhist(rgb2gray(outputRGB));
        title(ax3_hist, 'Enhanced Histogram');

        % Show equalized image, plot its grayscale histogram
        imshow(outputEq, 'Parent', ax4);
        title(ax4, 'Equalized');
        axes(ax4_hist);
        imhist(rgb2gray(outputEq));
        title(ax4_hist, 'Equalized Histogram');

        % Display denoised and sharpened images in another window with histograms
        fig3 = figure('Name', 'Processed Images - Part 2', 'Position', [200, 200, 800, 600], ...
                      'Units', 'pixels', 'Color', bgColor);
        uicontrol('Style', 'text', 'String', 'Processed Images - Denoised and Sharpened', ...
            'Units', 'normalized', 'Position', [0.1, 0.92, 0.8, 0.05], ...
            'BackgroundColor', bgColor, 'ForegroundColor', [0.2, 0.3, 0.4], ...
            'FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');

        % Create axes for denoised and sharpened images with their histograms
        ax5 = axes('Parent', fig3, 'Position', [0.1, 0.55, 0.35, 0.35]);
        ax5_hist = axes('Parent', fig3, 'Position', [0.1, 0.1, 0.35, 0.35]);
        ax6 = axes('Parent', fig3, 'Position', [0.55, 0.55, 0.35, 0.35]);
        ax6_hist = axes('Parent', fig3, 'Position', [0.55, 0.1, 0.35, 0.35]);

        % Display denoised image and its histogram for noise reduction analysis
        imshow(med_output, 'Parent', ax5);
        title(ax5, 'Denoised');
        axes(ax5_hist);
        imhist(rgb2gray(med_output));
        title(ax5_hist, 'Denoised Histogram');

        % Display sharpened image and its histogram for clarity enhancement analysis
        imshow(sharp_output, 'Parent', ax6);
        title(ax6, 'Sharpened');
        axes(ax6_hist);
        imhist(rgb2gray(sharp_output));
        title(ax6_hist, 'Sharpened Histogram');
    end
end
