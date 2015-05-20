function [ errorImage, mse ] = meanSquaredErrorImage( image1, image2 )

errorImage = (image1 - image2).^2;
errorImage = sum(errorImage, 3);

mse = mean(errorImage(:));

end

