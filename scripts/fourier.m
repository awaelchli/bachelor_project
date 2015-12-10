close all;
clc;

I = imread('output/epi_1x500x1000x1000/scanY=641.png');
Igray = rgb2gray(I);

f = fft2(double(Igray));
% Taking the spectrum with log scaling
f = log(1 + abs(f));
% Putting DC in the middle:
spectrum = fftshift(f);
% finding maximum in spectrum:
maximum = max(max(spectrum));
minimum = min(min(spectrum));
% scaling maximum to 255 and minimum to 0:
spectrum = (spectrum - minimum) / (maximum - minimum);
% Casting to uint8 to be able to display:
figure;
imagesc(spectrum);