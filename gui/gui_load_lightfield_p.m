function [ lightfield ] =  gui_load_lightfield_p( handles )

% Default
lightfield = [];

inputFolder = fullfile(get(handles.editPath, 'String'), filesep);
angularResY = str2double(get(handles.editAngularResY, 'String'));
angularResX = str2double(get(handles.editAngularResX, 'String'));
angularResolution = [angularResY, angularResX];
resizeScale = get(handles.sliderSpatialScale, 'Value');

filetypeStr = get(handles.popupFileType, 'String');
filetypeVal = get(handles.popupFileType, 'Value');
filetype = filetypeStr(filetypeVal, :);

switch get(handles.popupDataType, 'Value')
    case 1 % Image Collection
        handles.data.editor.inputFromImageCollection(inputFolder, filetype, angularResolution, resizeScale);
    case 2 % MATLAB File
    case 3 % Lytro File
end

baseline = [str2double(get(handles.editBaselineY, 'String')), str2double(get(handles.editBaselineX, 'String'))];
sensorSize = [str2double(get(handles.editSensorSizeY, 'String')), str2double(get(handles.editSensorSizeX, 'String'))];
cameraPlaneZ = str2double(get(handles.editCameraPlaneZ, 'String'));
sensorPlaneZ = str2double(get(handles.editSensorPlaneZ, 'String'));


if any(isnan(baseline))
    gui_warning(handles.textImportInfo, 'Invalid baseline');
    return;
end
handles.data.editor.distanceBetweenTwoCameras = baseline ./ (handles.data.editor.angularResolution - 1);

if any(isnan(sensorSize))
    gui_warning(handles.textImportInfo, 'Invalid size of image plane');
    return;
end
handles.data.editor.sensorSize = sensorSize;

if isnan(cameraPlaneZ)
    gui_warning(handles.textImportInfo, 'Invalid Z value for camera plane');
    return;
end
handles.data.editor.cameraPlaneZ = cameraPlaneZ;

if isnan(sensorPlaneZ)
    gui_warning(handles.textImportInfo, 'Invalid Z value for image plane');
    return;
end
handles.data.editor.sensorPlaneZ = sensorPlaneZ;

lightfield = handles.data.editor.getPerspectiveLightField();
            
    


end

