close all;
clc;

% inputEPI = 'thesis/Document/Figures/epi_1x500x1000x1000/scanY=641.png';
inputEPI = 'thesis/Document/Figures/epi_1x500x1000x1000/rectified/scanY=641.png';
% inputEPI = 'lightFields/constant/one_object.png';
% inputEPI = 'lightFields/constant/two_objects.png';

%% Read input
I = imread(inputEPI);
Igray = rgb2gray(I);

%% Windowing
% Using Hann window

[M, N] = size(Igray);
w1 = hann(M)';
w2 = hann(N)';
w = w1' * w2;
IgrayWindowed = im2uint8(im2single(Igray) .* w);

figure;
imshow(IgrayWindowed)

Igray = IgrayWindowed;

%% Padding

Igray = padarray(Igray, [300, 300], 0);
figure;
imshow(Igray);

%% Fourier transform

f = fft2(double(Igray));
% Taking the spectrum with log scaling
f = log(1 + abs(f));
% Putting DC in the middle:
spectrum = fftshift(f);
% Finding maximum in spectrum:
maximum = max(max(spectrum));
minimum = min(min(spectrum));
% Scaling maximum to 255 and minimum to 0:
spectrum = (spectrum - minimum) / (maximum - minimum);

%% Display spectrum

figure;
imshow(spectrum);
title('$ \log (1 + \textrm{abs} ( \hat{f} ) )$', 'interpreter', 'latex');

figure;
clamp = 0.5;
imshow(spectrum > clamp);
title(sprintf('$ \log (1 + \textrm{abs} ( \hat{f} ) ) > %i$', clamp), 'interpreter', 'latex');

