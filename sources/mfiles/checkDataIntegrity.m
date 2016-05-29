%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Checks if recordings within data/MEG_AD_Thesis/MEG_50863_noECG_10s
%%% contain any values other than double such as NUL.
%%%
%%% Author: Dragos Stanciu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set up global variables
setUpGlobals();
global CLEANED_EPOCHS_PATH;

% Get all files with recordings within the 'MEG_50863_noECG_10s' directory.
fileList = getAllFilesInDirectory(CLEANED_EPOCHS_PATH);

% Load recordings from each file and check for invalid values
for i=1:length(fileList)
    
    mat = load(fileList{i});
    
    % Validate with following syntax: validateattributes(array, classes, attributes)
    
    recordings = mat.meg_no_ecg;
    % check that the recordings have double values and no NaN elements
    validateattributes(recordings, {'double'}, {'nonnan'})
    
    epochNo = mat.thisEpoch;
    % check that the epoch number is valid
    validateattributes(epochNo, {'double'}, {'nonnan','positive','>',0,'<=',33})
    
    subjectID = mat.thisSubject;
    % check that the subjectID is a char
    validateattributes(subjectID, {'char'}, {})
    
    % Check that the number of rows (channels) is 148 for all epochs
    if size(recordings, 1) ~= 148
        fileList{i}
    end
    
    % Check that the number of columns (timesamples) is 1695 for all epochs
    if size(recordings, 2) ~= 1695
        fileList{i}
    end
    
end
