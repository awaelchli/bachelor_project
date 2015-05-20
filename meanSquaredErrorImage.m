function [ errorImage, mse ] = meanSquaredErrorImage( image1, image2 )

errorImage = 255*255*(image1 - image2).^2;
errorImage = sum(errorImage, 3);

mse = sqrt(mean(errorImage(:)));
errorImage = errorImage/255/255;
end

