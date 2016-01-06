
folder = 'lightFields/dice/perspective/1x500x1000x1000/';
out = [folder '/rectified/'];

disparityShift = [0, 0.5];

resolution = [1, 500, 1000, 1000, 3];
            
% cutSizesTop = (resolution(LightField.angularDimensions(1)) - 1) * disparityShift(1) : -disparityShift(1) : 0;
cutSizesLeft = (resolution(LightField.angularDimensions(2)) - 1) * disparityShift(2) : -disparityShift(2) : 0;
% newHeight = resolution(LightField.spatialDimensions(1)) - cutSizesTop(1);
newHeight = resolution(3);
newWidth = resolution(LightField.spatialDimensions(2)) - cutSizesLeft(1);
newWidth = floor(newWidth);

% rectifiedData = zeros([resolution(LightField.angularDimensions), newHeight, newWidth, resolution(LightField.channelDimension)]);

imageList = dir([folder '*.png']);

for cy = 1 : resolution(LightField.angularDimensions(1))
    for cx = 1 : resolution(LightField.angularDimensions(2))

        i = sub2ind(resolution([1, 2]), cy, cx);
        
        image = imread([folder imageList(i).name]);
%         top = cutSizesTop(cy);
        top = 0;
        left = ceil(cutSizesLeft(cx));
        rectifiedImage = image(top + 1 : top + newHeight, left + 1 : left + newWidth, :);
        
        
        imwrite(rectifiedImage, [out imageList(i).name]);
        
    end
end