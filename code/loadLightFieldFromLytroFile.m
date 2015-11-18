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

FileOptions = LFDefaultField('FileOptions', 'SaveResult', true);
FileOptions = LFDefaultField('FileOptions', 'SaveFnamePattern', '%s_Decoded.mat');

DecodeOptions = LFDefaultField('DecodeOptions', 'WhiteImageDatabasePath', whiteImageDatabasePath);
DecodeOptions = LFDefaultField('DecodeOptions', 'OptionalTasks', {'ColourCorrect'});

LFUtilUnpackLytroArchive(lytroCameraPath);
LFUtilProcessWhiteImages(lytroCameraPath);
LFUtilDecodeLytroFolder(file, FileOptions, DecodeOptions, []);

[path, name, ~] = fileparts(file);
load([path '/' name '_Decoded.mat']);

lightFieldData = LFHistEqualize(LF);
lightFieldData = lightFieldData(:, :, :, :, 1 : 3);
lightFieldData = single(lightFieldData);
metadata = LFMetadata;

end

