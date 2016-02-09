function gui_load_light_field_from_image_collection( hObject, handles )

set(handles.textImportInfo, 'String', 'Loading ...');
set(hObject, 'Enable', 'off');
drawnow;

switch get(handles.popupProjectionType, 'Value')
    case 1
        lightfield = gui_load_lightfield_p(handles);
    case 2
        lightfield = gui_load_lightfield_o(handles);
end

if(isempty(lightfield))
   return;
end
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

