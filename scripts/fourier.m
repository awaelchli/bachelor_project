close all;
clc;

I = imread('thesis/Document/Figures/epi_1x500x1000x1000/scanY=379.png');
% I = imread('scripts/epi.png');

% h = fspecial('disk', 4);
% I = imfilter(I, h, 'replicate');

Igray = rgb2gray(I);

%% Windowing
[M, N] = size(Igray);
w1 = cos(linspace(-pi/2, pi/2, M));
w2 = cos(linspace(-pi/2, pi/2, N));
w = w1' * w2;
f2 = im2uint8(im2single(Igray) .* w);
imshow(f2)

Igray = f2;
%%
figure;
imshow(Igray);

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


figure;
imshow(spectrum);

figure;
imshow(spectrum > 0.4);



%% Artificially create Fourier image and apply inverse Fourier transform

% Size of the image
s = 500;

% Specify slope of the two lines
slope1 = -5;
slope2 = -1.5;

m1 = createLineMask(s, slope1, 4 * s);
m2 = createLineMask(s, slope2, 4 * s);

m = m1 | m2;

figure;
imshow(m);

convolution = conv2(m1, m2);

figure; 
imshow(convolution);


slopes = -5 : 0.5 : -1.5;

m = createLineMask(s, slopes(1), 4 * s);
convolution = m;

for i = 2 : numel(slopes)
    
    m1 = createLineMask(s, slopes(i), 4 * s);
    
    convolution = conv2(convolution, m1);
    
end

figure;
imshow(convolution);

