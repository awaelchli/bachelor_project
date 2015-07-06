function tests = testLightFieldEditor

    tests = functiontests(localfunctions);

end

function setupOnce(testCase)
    
    testCase.TestData.imageFolder = 'temp/';
    mkdir(testCase.TestData.imageFolder);
    lightFieldData = rand(9, 9, 50, 50, 3);
    storeLightFieldDataAsImages(lightFieldData, testCase.TestData.imageFolder);
    
end

function teardownOnce(testCase) 

    rmdir(testCase.TestData.imageFolder, 's');
    
end

function testLoadingFromImageFolder(testCase)

    editor = LightFieldEditor();
    editor.inputFromImageCollection(testCase.TestData.imageFolder, 'png', [9, 9], 1);
    editor.cameraPlaneZ = 100;
    editor.distanceBetweenTwoCameras = [2, 3];
    editor.sensorSize = [40, 60];
    editor.sensorPlaneZ = -1;
    result = editor.getPerspectiveLightField();
    assertEqual(testCase, result.cameraPlane.z, 100);
    assertEqual(testCase, result.cameraPlane.distanceBetweenTwoCameras, [2, 3]);
    assertEqual(testCase, result.sensorPlane.planeSize, [40, 60]);
    assertEqual(testCase, result.sensorPlane.z, -1);
    assertEqual(testCase, result.resolution, [9, 9, 50, 50]);
    assertEqual(testCase, result.channels, 3);
    
end

function testSlicing(testCase)

    editor = LightFieldEditor();
    editor.inputFromImageCollection(testCase.TestData.imageFolder, 'png', [9, 9], 1);
    editor.angularSliceY(1 : 2 : 9);
    editor.angularSliceX([1, 2, 3]);
    result = editor.getPerspectiveLightField();
    assertEqual(testCase, result.angularResolution, [5, 3]);
    
    editor.angularSliceX([1, 2]);
    result = editor.getPerspectiveLightField();
    assertEqual(testCase, result.angularResolution, [5, 2]);
    
    editor.spatialSliceY(1);
    editor.spatialSliceX([1 : 48, 50]);
    result = editor.getPerspectiveLightField();
    assertEqual(testCase, result.angularResolution, [5, 2]);
    assertEqual(testCase, result.spatialResolution, [1, 49]);
    
    % TODO: Test invalid slices
    
end
