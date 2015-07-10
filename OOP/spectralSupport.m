
numberOfLightFields = 5;
sensorPlaneZValues = -5 : 0.2 : 5;

spatialResolution = [1, 100];
angularResolution = [1, 15];

cameraPlane = CameraPlane(angularResolution, [0.1, 0.1], 10);
attenuator = Attenuator(3, spatialResolution, [1, 1], 1, 3);



recFourierImages = cell(numberOfLightFields, numel(sensorPlaneZValues));
fourierImages = cell(numberOfLightFields, numel(sensorPlaneZValues));

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
        rec.computeAttenuationLayers();
        rec.reconstructLightField();
        recLF = rec.reconstructedLightField.lightFieldData;
        recLF = squeeze(recLF(:, :, :, :, 1));
        
        recFourierImages{n, iz} = fft2(recLF);
        fourierImages{n, iz} = fft2(squeeze(lightField.lightFieldData(:, :, :, :, 1)));

    end
end

recFourierImageStack = cat(3, recFourierImages{5, :});
recAverageFourierImage = fftshift(recFourierImageStack); 
recAverageFourierImage = abs(recAverageFourierImage);
recAverageFourierImage = log(recAverageFourierImage+1);
recAverageFourierImage = mat2gray(recAverageFourierImage);
recAverageFourierImage = mean(recAverageFourierImage, 3);       


fourierImageStack = cat(3, fourierImages{5, :});
averageFourierImage = fftshift(fourierImageStack);        
averageFourierImage = abs(averageFourierImage);
averageFourierImage = log(averageFourierImage+1);
averageFourierImage = mat2gray(averageFourierImage);
averageFourierImage = mean(averageFourierImage, 3);

figure;
subplot(211);
imshow(recAverageFourierImage, []);
subplot(212);
imshow(averageFourierImage, []);