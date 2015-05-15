path = 'lightFields/legotruck_downsampled_non_rect/';
out = 'lightFields/legotruck_downsampled_cropped_small/';
filetype = 'png';


if(exist(out, 'dir'))
    rmdir(out, 's');
end
mkdir(out);


% Load folder
imgList = dir([path '*.' filetype]);
numImages = size(imgList);

for i = 1 : numImages
    image = im2double(imread([path num2str(i) '.' filetype]));
    image = imcrop(image, [70, 290, 100, 100]);
    imwrite(image, [out sprintf('%04d', i) '.png']);
end