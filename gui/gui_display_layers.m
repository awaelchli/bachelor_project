function gui_display_layers( handles )

switch handles.data.axesLayersDisplayMode
    case handles.constants.displayMode.layers % display attenuation layers
        % TODO
    case handles.constants.displayMode.backprojection % display back projection
        axes(handles.axesLayersPreview);
        imshow(squeeze(handles.data.backprojection(handles.data.axesLayersPage, :, :, :)));
        axis equal image;
end

end

