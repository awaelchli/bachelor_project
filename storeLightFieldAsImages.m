%%

folder = 'temp/';

if(exist(folder, 'dir'))
    rmdir(folder, 's');
end
mkdir(folder);

filenumber = 1;
for y = 1 : size(lightField, 1)
    for x = 1 : size(lightField, 2)
        
        imwrite(squeeze(lightField(y, x, :, :, :)), [folder sprintf('%04d', filenumber) '.png']);
        filenumber = filenumber + 1;
    end
end
