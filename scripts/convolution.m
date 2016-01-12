close all;
clc;

input1 = 'output/fft3.mat';
input2 = 'output/fft4.mat';

%% Read input

load(input1, 'f');
fft1 = f;
load(input2, 'f');
fft2 = f;

figure;
subplot(1, 2, 1); 
imagesc(fftshift(fft1));
axis equal image;
subplot(1, 2, 2);
imagesc(fftshift(fft2));
axis equal image;

%% Convolution
c = conv2(fft1, fft2);

%% Display

figure;
imagesc(c);
axis equal image;
title('Convolution of Fourier images');

fprintf('Minimum of response: %i \n', min(abs(c(:))));
fprintf('Maximum of response: %i \n', max(abs(c(:))));
