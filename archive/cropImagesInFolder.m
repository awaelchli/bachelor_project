inputPath = 'temp/1x11_thermal/';
outputPath = 'temp/1x11_thermal_cropped/';
filetype = 'jpg';


if(exist(outputPath, 'dir'))
    rmdir(outputPath, 's');
end
mkdir(outputPath);


% Load folder
imageList = dir([inputPath '*.' filetype]);
numOfImages = size(imageList);

for i = 1 : numOfImages
    image = im2double(imread([inputPath imageList(i).name ]));
    image = imcrop(image, [0, 0, size(image, 2), 320]);
    imwrite(image, [outputPath sprintf('%04d', i) '.png']);
end