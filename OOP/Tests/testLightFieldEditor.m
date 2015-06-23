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
    editor.loadData(testCase.TestData.imageFolder, 'png', [9, 9], 1);
    editor.cameraPlaneZ = 100;
    editor.distanceBetweenTwoCameras = [2, 3];
    editor.sensorSize = [40, 60];
    editor.sensorPlaneZ = -1;
    result = editor.getLightField();
    assertEqual(testCase, result.cameraPlaneZ, 100);
    assertEqual(testCase, result.distanceBetweenTwoCameras, [2, 3]);
    assertEqual(testCase, result.sensorSize, [40, 60]);
    assertEqual(testCase, result.sensorPlaneZ, -1);
    
end

