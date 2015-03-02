function printToPDF( img, size, filename )
%   img:            Image matrix
%   size:           [width height] size of the image in mm
%   filename:       The filename (or path) of the pdf file to be created

fig = figure('Menubar', 'none');
subplot('Position', [0 0 1 1]), image(img);
set(gca, 'XTickLabel', [], 'YTickLabel', [])
set(gca, 'XTick', [], 'YTick', [])
% axis off
set(fig, 'PaperPositionMode', 'manual')
set(fig, 'PaperUnits', 'centimeters')
set(fig, 'PaperPosition',[0 0 size(1) / 10 size(2) / 10])
set(fig, 'PaperType', 'A4')
set(fig, 'PaperOrientation', 'portrait')

print('-dpdf', '-r0', filename);

end

