function gui_generate_PDF( handles )

from = str2double(get(handles.editPrintFrom, 'String'));
to = str2double(get(handles.editPrintTo, 'String'));
matrixSize = [str2double(get(handles.editMatrixSizeY, 'String')), str2double(get(handles.editMatrixSizeX, 'String'))];
markerSize = 0;

if any(isnan([from, to])) || any([from, to] <= 0) || any(rem([from, to], 1) ~= 0) || to < from
    gui_warning(handles.textPrintInfo, 'Invalid layer index');
    return;
end

if any(isnan(matrixSize)) || any(matrixSize <= 0) || any(rem(matrixSize, 1) ~= 0) || prod(matrixSize) < to - from + 1
    gui_warning(handles.textPrintInfo, 'Invalid size for arrangement matrix');
    return;
end

if get(handles.checkboxMarkers, 'Value')
    markerSize = str2double(get(handles.editMarkerSize, 'String'));
    if isnan(markerSize) || markerSize <= 0 || rem(markerSize, 1) ~= 0
        gui_warning(handles.textPrintInfo, 'Marker size must be a positive integer');
        return;
    end
end

n = to - from + 1;

matrix = zeros(matrixSize)';
matrix(1 : n) = from : to;
matrix = matrix';


[ filename, path, ~ ] = uiputfile('*.pdf', 'Save PDF', ['Print_Layers' sprintf('-%i', (from : to)')]);
[ ~, name, ~] = fileparts(filename); 

handles.data.evaluation.outputFolder = path;
handles.data.evaluation.printLayers(matrix, markerSize, name);

open(fullfile(path, filename));

end

