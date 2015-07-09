
numberOfLightFields = 1;
sensorPlaneZValues = -5 : 0.2 : 5;

spatialResolution = [1, 100];
angularResolution = [1, 15];

cameraPlane = CameraPlane(angularResolution, [0.1, 0.1], 10);
attenuator = Attenuator(3, spatialResolution, [1, 1], 1, 3);
resamplingPlane = SensorPlane(spatialResolution, attenuator.planeSize, -1);


recFourierImages = cell(numberOfLightFields, numel(sensorPlaneZValues));

for n = 1 : numberOfLightFields
    for iz = 1 : numel(sensorPlaneZValues)
        
        z = sensorPlaneZValues(iz);
        
        data = randn(100, 100);
        data = repmat(data, 1, 1, 15, 15, 3);
        data = permute(data, [3, 4, 1, 2, 5]);
        data = data(1, :, 1, :, :);

        sensorPlane = SensorPlane(spatialResolution, attenuator.planeSize, z);
        lightField = LightFieldP(data, cameraPlane, sensorPlane);

        rec = ReconstructionForResampledLF_V2(lightField, attenuator, resamplingPlane);
        rec.computeAttenuationLayers();
        rec.reconstructLightField();
        recLF = rec.reconstructedLightField.lightFieldData;
        recLF = squeeze(recLF(:, :, :, :, 1));
        F = fftshift(fft2(recLF));        
        F = abs(F);
        F = log(F+1);
        F = mat2gray(F);

        recFourierImages{n, iz} = F;
        
    end
end

recFourierImageStack = cat(3, recFourierImages{:});
averageFourierImage = sum(recFourierImageStack, 3);
figure;
imshow(averageFourierImage, []);