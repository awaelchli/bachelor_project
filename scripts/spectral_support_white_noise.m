%% Spectral support using white noise
%
%
%% Input data

width = 1000;
height = 1000;
spatial_cut_off = 100;
epsilon = 1;
N = 2;

%% Create white noise along lines in Fourier domain 

ds_du = linspace(-0.5, 0.5, N);
sz = [height, width];
fs = cell(1, N);

figure;

for i = 1 : N
    
    xi_s = linspace(-width / 2, width / 2, width);
    xi_u = linspace(height / 2, -height / 2, height)';
    xi_s = repmat(xi_s, [size(xi_u, 1), 1]);
    xi_u = repmat(xi_u, [1, size(xi_s, 2)]);

    cut_off_mask = abs(xi_s) <= spatial_cut_off;
%     mask = normpdf(ds_du(i) * xi_s + xi_u, 0, 2);
    mask = abs(ds_du(i) * xi_s + xi_u) <= epsilon;

    f_rand = 100 * (rand(sz) + 1i * rand(sz));
    f_rand = f_rand .* mask;
    f_rand(~cut_off_mask) = 0;
    
    fs{i} = f_rand;
    
    subplot(1, N, i);
    imagesc(log(1 + abs(fs{i})));
    axis equal image;
    colormap jet;
    
end

%% Repeated convolution of Fourier images

c = fs{1};
for i = 2 : N
    
    fprintf('Convolution %i ...', i - 1);
    
    c = conv2(c, fs{i}, 'same');
    
    fprintf('Done with convolution %i \n', i - 1);
    
end

figure; 
imagesc(log(1 + abs(c)));
colormap jet;
axis equal image;

%% Save convolution

im = log(1 + abs(c));
im = (im - min(im(:))) / (max(im(:)) - min(im(:)));

rgb = ind2rgb(gray2ind(im, 255), jet(255));
filename = ['output/convolution_' num2str(N) '_layers.png'];
imwrite(rgb, filename);