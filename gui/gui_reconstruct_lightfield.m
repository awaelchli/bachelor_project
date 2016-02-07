function [ evaluation ] = gui_reconstruct_lightfield( handles )


layerResolution = handles.data.attenuator.planeResolution;
attenuatorSize = handles.data.attenuator.planeSize;
z = handles.data.lightfield.sensorPlane.z;

% For the reconstruction, use a propagation matrix that projects from the sensor plane instead of the sampling plane
resamplingPlane = SensorPlane(round(1 * layerResolution), round(1 * attenuatorSize), z);
rec = FastReconstructionForResampledLF(handles.data.lightfield, handles.data.attenuator, resamplingPlane);
rec.constructPropagationMatrix();

rec.usePropagationMatrixForReconstruction(rec.propagationMatrix);
% rec.reconstructLightField();

evaluation = rec.evaluation;

indY = 1 : rec.lightField.angularResolution(1);
indX = 1 : rec.lightField.angularResolution(2);
indY = repmat(indY, numel(indX), 1);
indX = repmat(indX, 1, size(indY, 2));
indices = [indY(:), indX(:)];

evaluation.evaluateViews(indices);


end

