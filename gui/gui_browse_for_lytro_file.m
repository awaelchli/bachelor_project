function gui_browse_for_lytro_file( handles )

[filename, path, ~] = uigetfile('*.lfr', 'Select Lytro file');
if filename == 0 % User cancelled
    return;
end

set(handles.editPath, 'String', fullfile(path, filename));

% TODO: Predict angular resolution


end

