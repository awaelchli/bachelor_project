%%

folder = 'lightFields/legotruck_downsampled/';

if(exist(folder, 'dir'))
    rmdir(folder, 's');
end
mkdir(folder);

filenumber = 1;
for y = 1 : size(lightField, 1)
    for x = 1 : size(lightField, 2)
        
        imwrite(squeeze(lightField(y, x, :, :, :)), [folder num2str(filenumber) '.png']);
        filenumber = filenumber + 1;
    end
end
