function gui_load_light_field_from_lytro_file( hObject, handles )

% Read lytro camera path
if ~exist(handles.constants.lytroSettingsFile, 'file')
    lytro_settings;
    return;
end
load(handles.constants.lytroSettingsFile, 'lytroPath');

% Read the light field file
lytroFile = get(handles.editPath, 'String');
if ~exist(lytroFile, 'file')
    gui_warning(handles.textImportInfo, 'Invalid path');
    return;
end

set(handles.textImportInfo, 'String', 'Loading ...');
set(hObject, 'Enable', 'off');
drawnow;

resizeScale = get(handles.sliderSpatialScale, 'Value');
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

if all(isnan([sliceFromY, sliceToY, sliceFromX, sliceToX, sliceStepY, sliceStepX]))
    % Assume user wants full resolution 
    % Load the light field
    [lightFieldData, metadata] = loadLightFieldFromLytroFile(lytroFile, lytroPath);
    lightFieldRaw = LightField(lightFieldData);
    handles.data.editor.inputFromRawLightField(lightFieldRaw, resizeScale);
    
else % User has specified angular slices before the load operation
    
    % Load the light field ...
    [lightFieldData, metadata] = loadLightFieldFromLytroFile(lytroFile, lytroPath);
    lightFieldRaw = LightField(lightFieldData);
    handles.data.editor.inputFromRawLightField(lightFieldRaw, resizeScale);
    
    % ... and check if slices are valid for the light field
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
end

lightfield = handles.data.editor.getPerspectiveLightField();
handles.data.lightfield = lightfield;

set(handles.textImportInfo, 'String', 'Loading ... Done.');
set(hObject, 'Enable', 'on');
set(handles.btnAnimate, 'Enable', 'on');

% Update handles structure
guidata(hObject, handles);

% Update layer size and resolution
set(handles.editLayerSizeY, 'String', get(handles.editSensorSizeY, 'String'));
set(handles.editLayerSizeX, 'String', get(handles.editSensorSizeX, 'String'));
set(handles.editLayerResY, 'String', handles.data.lightfield.spatialResolution(1));
set(handles.editLayerResX, 'String', handles.data.lightfield.spatialResolution(2));

gui_display_image(handles.axesLFPreview);

end

