
numberOfLightFields = 100;
sensorPlaneZValues = 0;

spatialResolution = [1, 100];
angularResolution = [1, 15];

thickness = 3;
N = 8;
cameraPlane = CameraPlane(angularResolution, [0.1, 0.1], 10);
attenuator = Attenuator(N, spatialResolution, [1, 1], thickness / (N-1), 3);



recFourierImages = cell(numberOfLightFields, numel(sensorPlaneZValues));
fourierImages = cell(numberOfLightFields, numel(sensorPlaneZValues));

lengthLastOutput = 0;

for n = 1 : numberOfLightFields
    
    data = randn(100, 100);
    data = repmat(data, 1, 1, 15, 15, 3);
    data = permute(data, [3, 4, 1, 2, 5]);
    data = data(1, :, 1, :, :);
    
    
    for iz = 1 : numel(sensorPlaneZValues)
        
        z = sensorPlaneZValues(iz);
        resamplingPlane = SensorPlane(spatialResolution, attenuator.planeSize, z);
        sensorPlane = SensorPlane(spatialResolution, attenuator.planeSize, z);
        lightField = LightFieldP(data, cameraPlane, sensorPlane);

        rec = ReconstructionForResampledLF_V2(lightField, attenuator, resamplingPlane);
        rec.verbose = 0;
        rec.computeAttenuationLayers();
        rec.reconstructLightField();
        recLF = rec.reconstructedLightField.lightFieldData;
        recLF = squeeze(recLF(:, :, :, :, 1));
        
        recFourierImages{n, iz} = fft2(recLF);
        fourierImages{n, iz} = fft2(squeeze(lightField.lightFieldData(:, :, :, :, 1)));
        
        out = sprintf('%i', iz);
        fprintf(repmat('\b', 1, lengthLastOutput));
        fprintf(out);
        lengthLastOutput = numel(out);
    end
    lengthLastOutput = 0;
    fprintf('\n');
end

recFourierImageStack = cat(3, recFourierImages{1, :});
recAverageFourierImage = fftshift(recFourierImageStack); 
recAverageFourierImage = abs(recAverageFourierImage);
recAverageFourierImage = log(recAverageFourierImage+1);
recAverageFourierImage = mean(recAverageFourierImage, 3);       


fourierImageStack = cat(3, fourierImages{1, :});
averageFourierImage = fftshift(fourierImageStack);        
averageFourierImage = abs(averageFourierImage);
averageFourierImage = log(averageFourierImage+1);
averageFourierImage = mean(averageFourierImage, 3);

NZrecAverageFourierImage = recAverageFourierImage / max(recAverageFourierImage(:));

NZrecAverageFourierImage(NZrecAverageFourierImage <= 0.3) = 0;
NZrecAverageFourierImage(NZrecAverageFourierImage > 0.3) = 1;

figure;
subplot(311);
imshow(recAverageFourierImage, []);
subplot(312);
imshow(NZrecAverageFourierImage, []);
subplot(313);
imshow(averageFourierImage, []);