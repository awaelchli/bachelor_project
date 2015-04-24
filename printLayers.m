function printLayers( layers, layerSize, outFolder, filename, count )
%   layers:
%   layerSize:      [width height] size of the image in mm
%   outFolder:      The path to the folder where the images will be stored
%                   in
%   filename:       The filename of the pdf file to be created (without the
%                   .pdf extension)

padding = floor(size(layers, 1) / 15);
resolution = [size(layers, 1), size(layers, 2)];
h = resolution(1) + 2 * padding;
w = resolution(2) + 2 * padding;
Nlayers = size(layers, 3);
channels = size(layers, 4);

images = zeros(h, w, channels, Nlayers);

for layer = 1 : Nlayers
    % current image of layer
    im = cat(3, squeeze(layers(:, :, layer, :)));
    
    % add padding to image
    im = padarray(im, [padding, padding], 1);
    
    % insert markers that help for alignment
    offset = floor(padding / 2);
    pos = [offset offset;
        w - offset offset;
        offset h - offset];
%     im = insertMarker(im, pos, 'Color', 'Black', 'Size', offset);
    
    % insert layer number
%     im = insertText(im, [w - offset h - offset], count, ...
%         'AnchorPoint', 'Center', 'BoxOpacity', 0, ...
%         'FontSize', 16);
    
    
    % save images and print to pdf
    imwrite(im, [outFolder num2str(count) '.png']);
    
    count = count + 1;
    
    images(:, :, :, layer) = im;
end


fig = figure('Menubar', 'none');

for layer = 1 : Nlayers
    img = images(:, :, :, layer);
    
    relPosY = (layer - 1) / Nlayers;
    relSize = 1 / Nlayers;
    subplot('Position', [0, relPosY, relSize, relSize]), image(img)
    
    set(gca, 'XTickLabel', [], 'YTickLabel', [])
    set(gca, 'XTick', [], 'YTick', [])
end

pixelSize = layerSize ./ [resolution(2) resolution(1)];
padSize = pixelSize .* padding;
printSize = layerSize + 2 .* padSize;

set(fig, 'PaperPositionMode', 'manual')
set(fig, 'PaperUnits', 'centimeters')
set(fig, 'PaperPosition',[1, 1, printSize(1) * Nlayers / 10,  printSize(2) * Nlayers / 10])
set(fig, 'PaperType', 'A4')
set(fig, 'PaperOrientation', 'portrait')

print('-dpdf', '-r0', [outFolder filename '.pdf']);

end

