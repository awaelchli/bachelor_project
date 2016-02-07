function [ attenuator ] = gui_create_attenuator( handles )

attenuator = [];

numberOfLayers = get(handles.sliderLayers, 'Value');
thickness = str2double(get(handles.editThickness, 'String'));
layerSize = [str2double(get(handles.editLayerSizeY, 'String')), str2double(get(handles.editLayerSizeX, 'String'))];
layerResolution = [str2double(get(handles.editLayerResY, 'String')), str2double(get(handles.editLayerResX, 'String'))];
channels = 3;

if get(handles.checkboxGrayscale, 'Value')
    channels = 1;
end

if isnan(thickness)
    gui_warning(handles.textOptimizationInfo, 'Invalid attenuator thickness');
    return;
end

if any(isnan(layerSize))
    gui_warning(handles.textOptimizationInfo, 'Invalid layer size');
    return;
end

if any(isnan(layerResolution))
    gui_warning(handles.textOptimizationInfo, 'Invalid layer resolution');
    return;
end

attenuator = Attenuator(numberOfLayers, layerResolution, layerSize, thickness, channels);

end

