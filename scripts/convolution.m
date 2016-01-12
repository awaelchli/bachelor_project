close all;
clc;

input1 = 'output/fft1.mat';
input2 = 'output/fft2.mat';

%% Read input

load(input1, 'f');
fft1 = f;
load(input2, 'f');
fft2 = f;

c = conv2(fft1, fft2);