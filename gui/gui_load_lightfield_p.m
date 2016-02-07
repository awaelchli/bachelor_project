function [ lightfield ] =  gui_load_lightfield_p( handles )

% Default
lightfield = [];

inputFolder = fullfile(get(handles.editPath, 'String'), filesep);
angularResY = str2double(get(handles.editAngularResY, 'String'));
angularResX = str2double(get(handles.editAngularResX, 'String'));
angularResolution = [angularResY, angularResX];

if any(isnan(angularResolution))
    gui_warning(handles.textImportInfo, 'Invalid angular resolution');
    return;
end

resizeScale = get(handles.sliderSpatialScale, 'Value');
filetypeStr = get(handles.popupFileType, 'String');
filetypeVal = get(handles.popupFileType, 'Value');
filetype = filetypeStr(filetypeVal, :);

switch get(handles.popupDataType, 'Value')
    case 1 % Image Collection
        try
            handles.data.editor.inputFromImageCollection(inputFolder, filetype, angularResolution, resizeScale);
        catch me
            if strcmp(me.identifier, 'inputFromImageCollection:wrongAngularResolution')
                gui_warning(handles.textImportInfo, 'Invalid angular resolution');
                return;
            end
            if strcmp(me.identifier, 'inputFromImageCollection:invalidFolder')
                gui_warning(handles.textImportInfo, 'Path is not a folder');
                return;
            end
        end
    case 2 % MATLAB File
    case 3 % Lytro File
end

baseline = [str2double(get(handles.editBaselineY, 'String')), str2double(get(handles.editBaselineX, 'String'))];
sensorSize = [str2double(get(handles.editSensorSizeY, 'String')), str2double(get(handles.editSensorSizeX, 'String'))];
cameraPlaneZ = str2double(get(handles.editCameraPlaneZ, 'String'));
sensorPlaneZ = str2double(get(handles.editSensorPlaneZ, 'String'));

sliceFromY = str2double(get(handles.editAngularIndFromY, 'String'));
sliceStepY = str2double(get(handles.editAngularIndStepY, 'String'));
sliceToY = str2double(get(handles.editAngularIndToY, 'String'));

sliceFromX = str2double(get(handles.editAngularIndFromX, 'String'));
sliceStepX = str2double(get(handles.editAngularIndStepX, 'String'));
sliceToX = str2double(get(handles.editAngularIndToX, 'String'));

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

if any(isnan([sliceFromY, sliceStepY, sliceToY, sliceFromX, sliceStepX, sliceToX]))
    gui_warning(handles.textImportInfo, 'Invalid angular slice');
    return;
end

handles.data.editor.angularSliceY(sliceFromY : sliceStepY : sliceToY);
handles.data.editor.angularSliceX(sliceFromX : sliceStepX : sliceToX);

lightfield = handles.data.editor.getPerspectiveLightField();
            
    


end

