% close all;

editor = LightFieldEditor();
editor.inputFromImageCollection('lightFields/dice/perspective/1x100x1000x1000/', 'png', [1, 100], 1);

LF = editor.getOrthographicLightField();
data = LF.lightFieldData;

spatialResolution = LF.spatialResolution;
angularResolution = LF.angularResolution;

fixedY = 411;

left = squeeze(data(1, floor(LF.angularResolution(2) / 2), :, :, :));
epi = squeeze(data(:, :, fixedY, :, :));

figure(1);
subplot(1, 2, 1);
imagesc(left);
hold on;
plot([1 spatialResolution(2)], [fixedY, fixedY], 'Color', 'black');
axis equal tight;
subplot(1, 2, 2);
imagesc(epi);
axis equal tight;

while true
    
    [~, y, key] = ginput(1);
    
    if key == 27
        break;
    end
    
    y = max(floor(y), 1);
    
    epi = squeeze(data(:, :, y, :, :));
    
    figure(1);
    subplot(1, 2, 1);
    imagesc(left);
    hold on;
    plot([1 spatialResolution(2)], [y, y], 'Color', 'black');
    axis equal tight;
    hold off;
    
    subplot(1, 2, 2);
    imagesc(epi);
    axis equal tight;
end
