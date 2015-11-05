close all;

outputFolder = 'output/ortho/';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Load perspective light field data
editor = LightFieldEditor();
editor.inputFromImageCollection('lightFields/dice/perspective/3x3-.2_rect/', 'png', [3, 3], 1);
% editor.spatialSliceX(1 : 100);
% editor.spatialSliceY(1 : 100);

editor.distanceBetweenTwoCameras = [0.2 0.2];
d = 6;
editor.sensorPlaneZ = d;
perspectiveLF = editor.getPerspectiveLightField();

angularResolutionP = perspectiveLF.angularResolution;
spatialResolutionP = perspectiveLF.spatialResolution;

% Parameters for the orthographic projection
FOV = [10 10];
resolutionO = [10, 10, 600, 800];
sensorSize = 1;
sensorPlane = SensorPlane(resolutionO([3, 4]), sensorSize, d);
orthographicLF = LightFieldO(zeros([resolutionO 1]), sensorPlane, FOV);

angularResolutionO = orthographicLF.angularResolution;
spatialResolutionO = orthographicLF.spatialResolution;

angularIndicesY = 1 : orthographicLF.angularResolution(1);
angularIndicesX = 1 : orthographicLF.angularResolution(2);

rayAnglesY = arrayfun(@(i) orthographicLF.rayAngle([i, 1]) * [1, 0]', angularIndicesY);
rayAnglesX = arrayfun(@(i) orthographicLF.rayAngle([1, i]) * [0, 1]', angularIndicesX);

% Grid vectors for the perspective light field
Ug = perspectiveLF.cameraPlane.cameraPositionMatrixX(1, :);
Vg = perspectiveLF.cameraPlane.cameraPositionMatrixY(:, 1);
Sg = perspectiveLF.sensorPlane.pixelPositionMatrixX(1, :);
Tg = perspectiveLF.sensorPlane.pixelPositionMatrixY(:, 1);

% Grid vectors for the orthographic light field (query points)

T = orthographicLF.sensorPlane.pixelPositionMatrixY;
S = orthographicLF.sensorPlane.pixelPositionMatrixX;

phi = repmat(rayAnglesY', [1 angularResolutionO(2)]);
theta = repmat(rayAnglesX, [angularResolutionO(1) 1]);

dtanphi = d * tan(phi);
dtantheta = d * tan(theta);

dtanphi_rep = repmat(dtanphi, [1 1 spatialResolutionO]);
dtantheta_rep = repmat(dtantheta, [1 1 spatialResolutionO]);

T = permute(repmat(T, [1 1 angularResolutionO]), [3 4 1 2]);
S = permute(repmat(S, [1 1 angularResolutionO]), [3 4 1 2]);

V = T + dtanphi_rep;
U = S + dtantheta_rep;

O = interpn(Vg, Ug, Tg, Sg, squeeze(perspectiveLF.lightFieldData(:, :, :, :, 1)), V, U, T, S);

for i = 1 : angularResolutionO(1)
    for j = 1 : angularResolutionO(2)
        name = sprintf('(%s, %s).png', i, j);
        imwrite(squeeze(O(i, j, :, :, 1)), [outputFolder name]);
    end
end
