function gui_display_image( axesHandle )

    handles = guidata(axesHandle);

    axes(axesHandle);
    imshow(squeeze(handles.data.lightfield.lightFieldData(1, 1, :, :, :)));
    axis equal image;
    
end

