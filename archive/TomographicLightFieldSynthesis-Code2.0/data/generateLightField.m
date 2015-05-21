clear all; 
addpath('../');

% plot the data
bPlotData = true;
if bPlotData
    clf;
end

% path to output light field and folder containing the scene
outpath = 'dice';
%outpath = 'dragon';
%outpath = 'butterfly';
%outpath = 'planes';
%outpath = 'messerschmitt';
%outpath = 'xyzrgb_dragon';
%outpath = 'happy_buddha';
%outpath = 'mini';

% scale the output light field between this value and what was the maximum
% value
minLightFieldValue = 0.01;

% size of the light field [y x] [mm]
lightFieldSize      = [75 100];
%lightFieldSize      = [75 100].*1.2328;

% XXX change spatial resolution here, if you want smaller-res light fields! XXX
% desired resolution in [#anglesY @anglesX #pixelsY #pixelsX #colorchannels]
lightFieldResolution = [7 7 384 512 3]; % full-resolution, colored light field
%lightFieldResolution = [7 7 48 64 1]; % small, grayscale light field

% resolution of image files
lightFieldImageResolution = [384 512];

% use alpha channel - if this is true BG must be a background image 
bUseAlpha           = false;
if strcmp(outpath,'dice')==1
    bUseAlpha       = true;
end
gradientStartEnd    = [155 191];
gradientStartEnd    = [155-20 191+20];
BG                  = repmat((gradientStartEnd(1):(gradientStartEnd(2)-gradientStartEnd(1))/(lightFieldResolution(3)-1):gradientStartEnd(2))' ./ 255, [1 lightFieldResolution(4) lightFieldResolution(5)]);
BG                  = flipdim(BG,1);

%BG = 0.*BG+1;

% XXX change FOV here for messerschmitt [10 or 20 or 45] and dice [10 or 20] XXX
% field of view in degrees
fov = 10;

% path to images
if fov ~= 10
    datapath = [outpath '/' num2str(lightFieldResolution(1)) 'x' num2str(lightFieldResolution(2)) 'x' num2str(lightFieldImageResolution(1)) 'x' num2str(lightFieldImageResolution(2)) '_fov' num2str(fov) '/'];
else
    datapath = [outpath '/' num2str(lightFieldResolution(1)) 'x' num2str(lightFieldResolution(2)) 'x' num2str(lightFieldImageResolution(1)) 'x' num2str(lightFieldImageResolution(2)) '/'];
end

% max angle in both ways in v = tan(theta)
maxAngle            = tan(pi*fov/360);
lightFieldAnglesX   = -maxAngle:2*maxAngle/(lightFieldResolution(1)-1):maxAngle;
lightFieldAnglesY   = -maxAngle:2*maxAngle/(lightFieldResolution(2)-1):maxAngle;
                    
% origin of light field in world space [y x z]
lightFieldOrigin    = [0 0 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% basename for files with count < 10
filename = [datapath outpath '-'];
if (strcmp(outpath,'xyzrgb_dragon')==1) || (strcmp(outpath,'happy_buddha')==1)
    filename = [datapath outpath];
end
if lightFieldResolution(1)*lightFieldResolution(2)>10
   filename = [filename '0'];
end
if lightFieldResolution(1)*lightFieldResolution(2)>100
   filename = [filename '0'];
end
filetype = '.png';

% initialize light field
lightField = zeros(lightFieldResolution);

count = 1;
for ky=1:lightFieldResolution(1)
    for kx=1:lightFieldResolution(2)
                        
        currentFilename = [filename num2str(count) filetype];
        
        % load image
        if count > 9
            currentFilename = [filename(1:end-1) num2str(count) filetype];            
        end
        
        % load image
        if ~bUseAlpha
            I = im2double(imread(currentFilename));
        % load image and alpha
        else
            [I map alpha] = imread(currentFilename);
            I       = im2double(I);
            alpha   = im2double(alpha);
        end
        
        % convert to grayscale if desired
        if lightFieldResolution(5) == 1
            I = rgb2gray(I);
        end
        
        % resize image if desired
        if  (lightFieldResolution(3) ~= lightFieldImageResolution(1)) || ...
            (lightFieldResolution(4) ~= lightFieldImageResolution(2))
            I = imresize(I, [lightFieldResolution(3) lightFieldResolution(4)]);
            if bUseAlpha
                alpha = imresize(alpha, [lightFieldResolution(3) lightFieldResolution(4)]);
            end
        end
                       
        % change background using alpha
        if bUseAlpha
            I = (repmat(alpha, [1 1 size(I,3)])) .* I + (1-repmat(alpha, [1 1 size(I,3)])) .* BG;
        end
               
        lightField(ky,kx,:,:,:) = reshape(I, [1 1 lightFieldResolution(3) lightFieldResolution(4) lightFieldResolution(5)]);
        
        if bPlotData
            imshow(I); drawnow;
        end
        
        % increment counter
        count = count + 1;
    end
end

% scale light field
minMaxLF    = [ min(lightField(:)) max(lightField(:)) ];
if min(lightField(:)) < minLightFieldValue
    lightField  = ((lightField-minMaxLF(1)) ./ (minMaxLF(2)-minMaxLF(1))) .* (minMaxLF(2)-minLightFieldValue) + minLightFieldValue;
end

if bPlotData
    img = drawLightField4D(lightField);
    imshow(img);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save(['LightField4D.mat'], 'lightField', 'lightFieldAnglesY', 'lightFieldAnglesX', 'lightFieldSize', 'lightFieldResolution', 'lightFieldOrigin');

