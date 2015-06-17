function printLayers( layers, layerSize, outFolder, filename, count )
%   layers:
%   layerSize:      [width height] size of the image in mm
%   outFolder:      The path to the folder where the images will be stored
%                   in
%   filename:       The filename of the pdf file to be created (without the
%                   .pdf extension)

padding = floor(size(layers, 1) / 15);
originalLayerResolution = [size(layers, 1), size(layers, 2)];
NumberOfLayers = size(layers, 3);

layers = permute(layers, [1, 2, 4, 3]);
layers = padarray(layers, [padding, padding, 0, 0], 1);

newResolution = [size(layers, 1), size(layers, 2)];

for layer = 1 : NumberOfLayers
    
    currentLayer = layers(:, :, :, layer);

    % insert markers that help for alignment
    offset = floor(padding / 2);
%     pos = [offset offset;
%         w - offset offset;
%         offset h - offset];
%     im = insertMarker(im, pos, 'Color', 'Black', 'Size', offset);
    
    % Insert layer number into image
    currentLayer = insertTextIntoImage(currentLayer, num2str(count), newResolution([2, 1]) - offset, 16);
    
    % Save image of layer
    imwrite(currentLayer, [outFolder num2str(count) '.png']);
    
    count = count + 1;
    layers(:, :, :, layer) = currentLayer;
end


fig = figure('Menubar', 'none', 'Visible', 'off');

for layer = 1 : NumberOfLayers
    img = layers(:, :, :, layer);
    
    relPosY = (layer - 1) / NumberOfLayers;
    relSize = 1 / NumberOfLayers;
    subplot('Position', [0, relPosY, relSize, relSize]), image(im2uint8(img))
    
    set(gca, 'XTickLabel', [], 'YTickLabel', [])
    set(gca, 'XTick', [], 'YTick', [])
end

pixelSize = layerSize ./ [originalLayerResolution(2) originalLayerResolution(1)];
padSize = pixelSize .* padding;
printSize = layerSize + 2 .* padSize;

set(fig, 'PaperPositionMode', 'manual')
set(fig, 'PaperUnits', 'centimeters')
set(fig, 'PaperPosition',[1, 1, printSize(1) * NumberOfLayers / 10,  printSize(2) * NumberOfLayers / 10])
set(fig, 'PaperType', 'A4')
set(fig, 'PaperOrientation', 'portrait')

print('-dpdf', '-r0', [outFolder filename '.pdf']);

end

function [ imageWithText ] = insertTextIntoImage(image, textString, position, fontSize)

f = figure('Visible', 'off');
imshow(image);
text('Position', position, 'String', textString, 'FontSize', fontSize);

hFrame = getframe(gca);
imageWithText = hFrame.cdata;

close(f);

imageWithText = imageWithText(1 : size(image, 1), 1 : size(image, 2), 1 : size(image, 3));

end
