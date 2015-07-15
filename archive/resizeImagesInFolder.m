
path = 'lightFields/legotruck_non_rectified/';
out = 'lightFields/legotruck_downsampled_non_rect/';
filetype = 'jpg';
scaleFactor = 0.2;


if(exist(out, 'dir'))
    rmdir(out, 's');
end
mkdir(out);


% Load folder
imgList = dir([path '*.' filetype]);
numImages = size(imgList);

i = 1;
for y = 1 : numImages
    
    image = im2double(imread([path imgList(i).name]));
    image = imresize(image, scaleFactor, 'nearest');
    imwrite(image, [out num2str(i) '.png']);
    
    i = i + 1;

end