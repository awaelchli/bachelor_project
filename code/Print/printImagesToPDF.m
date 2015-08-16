function printImagesToPDF( outputFolder, filename, images, printSize )
% Prints all images from the input on one A4 paper and stores the result in a PDF file.

    numberOfImages = size(images, 1);
    fig = figure('Menubar', 'none', 'Visible', 'on');

    for imageNumber = 1 : numberOfImages
        
        img = squeeze(images(imageNumber, :, :, :));

        relPosY = (imageNumber - 1) / numberOfImages;
        relSize = 1 / numberOfImages;
        subplot('Position', [0, relPosY, relSize, relSize]), image(im2uint8(img));
        set(gca, 'XTickLabel', [], 'YTickLabel', []);
        set(gca, 'XTick', [], 'YTick', []);
    end

    set(fig, 'PaperPositionMode', 'manual')
    set(fig, 'PaperUnits', 'centimeters')
    set(fig, 'PaperPosition', [1, 1, printSize(1) * numberOfImages / 10, printSize(2) * numberOfImages / 10])
    set(fig, 'PaperType', 'A4')
    set(fig, 'PaperOrientation', 'portrait')
    
    print('-dpdf', '-r0', [outputFolder, filename, '.pdf']);
    
    close(fig);
    
end

