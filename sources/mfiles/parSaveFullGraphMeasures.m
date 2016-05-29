%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Utility function used to save results computed in the parallel loop of
%%% getFullGraphMeasures.m.
%%% Matlab needs this to determine which variables will be saved.
%%% 
%%% More info: http://www.mathworks.co.uk/matlabcentral/answers/135285-how-do-i-use-save-with-a-parfor-loop-using-parallel-computing-toolbox
%%%
%%% Author: Dragos Stanciu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function parSaveFullGraphMeasures(fileName, C, L, GE, SW, Q, threshold, bandName, subjectID, groupName, measure)
    save(fileName, 'C', 'L', 'GE', 'SW', 'Q', 'threshold', 'bandName', 'subjectID', 'groupName', 'measure');
end
