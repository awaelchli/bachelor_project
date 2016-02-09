function [ lightfield ] =  gui_load_lightfield_p( handles )

% Default
lightfield = [];

inputFolder = fullfile(get(handles.editPath, 'String'), filesep);
angularResY = str2double(get(handles.editAngularResY, 'String'));
angularResX = str2double(get(handles.editAngularResX, 'String'));
angularResolution = [angularResY, angularResX];

if any(isnan(angularResolution)) || any(angularResolution < 1) || any(rem(angularResolution, 1) ~= 0)
    gui_warning(handles.textImportInfo, 'Invalid angular resolution');
    return;
end

resizeScale = get(handles.sliderSpatialScale, 'Value');
filetypeStr = get(handles.popupFileType, 'String');
filetypeVal = get(handles.popupFileType, 'Value');
filetype = filetypeStr(filetypeVal, :);

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

if any(isnan(baseline)) || any(baseline <= 0) 
    gui_warning(handles.textImportInfo, 'Invalid baseline');
    return;
end
handles.data.editor.distanceBetweenTwoCameras = baseline ./ (handles.data.editor.angularResolution - 1);

if any(isnan(sensorSize)) || any(sensorSize <= 0) 
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

if any(isnan([sliceFromY, sliceToY])) || any([sliceFromY, sliceToY] < [1, 1]) || ... 
   any([sliceFromY, sliceToY] > handles.data.editor.angularResolution(1))
    gui_warning(handles.textImportInfo, 'Invalid range for angular slice for Y');
    return;
end

if any(isnan([sliceFromX, sliceToX])) || any([sliceFromX, sliceToX] < [1, 1]) || ... 
   any([sliceFromX, sliceToX] > handles.data.editor.angularResolution(2))
    gui_warning(handles.textImportInfo, 'Invalid range for angular slice for X');
    return;
end

if isnan(sliceStepY) || rem(sliceStepY, 1) ~= 0 || (sliceToY - sliceFromY) * sign(sliceStepY) < 0
    gui_warning(handles.textImportInfo, 'Invalid step for angular slice Y');
    return;
end

if isnan(sliceStepX) || rem(sliceStepX, 1) ~= 0 || (sliceToX - sliceFromX) * sign(sliceStepX) < 0
    gui_warning(handles.textImportInfo, 'Invalid step for angular slice X');
    return;
end

handles.data.editor.angularSliceY(sliceFromY : sliceStepY : sliceToY);
handles.data.editor.angularSliceX(sliceFromX : sliceStepX : sliceToX);

lightfield = handles.data.editor.getPerspectiveLightField();
            
    


end

