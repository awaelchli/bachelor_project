function [ b ] = gui_backprojection( handles )

layerResolution = handles.data.attenuator.planeResolution;
attenuatorSize = handles.data.attenuator.planeSize;
sensorPlaneZ = handles.data.lightfield.sensorPlane.z;

resamplingPlane = SensorPlane(round(1 * layerResolution), attenuatorSize, sensorPlaneZ);
rec = ReconstructionForResampledLF(handles.data.lightfield, handles.data.attenuator, resamplingPlane);

rec.constructPropagationMatrix();
b = rec.backprojectLightField();

% for i = 1 : handles.data.attenuator.numberOfLayers
%     figure('Name', sprintf('Layer %i', i));
%     imshow(squeeze(b(i, :, :, :)), []);
%     imwrite(squeeze(b(i, :, :, :)), sprintf('output/Back_Projection_Layer_%i.png', i));
% end

end

