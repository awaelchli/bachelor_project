function [lightFieldData, metadata] = loadLightFieldFromLytroFile( lytroFile, lytroCameraPath )
% lytroFile:                Path to the .lfr file
% lytroCameraPath:          Path to the installed camera, usually in C:/Users/username/AppData/Local/Lytro/cameras/.


file = fullfile(lytroFile);

whiteImageDatabasePath = fullfile(lytroCameraPath, 'WhiteImageDatabase.mat');

if(~exist(whiteImageDatabasePath, 'file'))
    error('The file "%s" does not exist.', whiteImageDatabasePath);
end

if(~exist(file, 'file'))
    error('The file "%s" does not exist.', file);
end

LFUtilUnpackLytroArchive(lytroCameraPath);
LFUtilProcessWhiteImages(lytroCameraPath);

DecodeOptions = LFDefaultField('DecodeOptions', 'WhiteImageDatabasePath', whiteImageDatabasePath);
[lightFieldData, metadata, ~] = LFLytroDecodeImage(file, DecodeOptions);

lightFieldData = lightFieldData(:, :, :, :, 1 : 3);
lightFieldData = single(lightFieldData);

fprintf('\n');

end

