%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Utility function used to save results computed in the parallel loop of
%%% getConnectivityMatrices.m.
%%%
%%% Matlab needs this to determine which variables will be saved.
%%% 
%%% Reference: http://www.mathworks.co.uk/matlabcentral/answers/135285-how-do-i-use-save-with-a-parfor-loop-using-parallel-computing-toolbox
%%%
%%% Author: Dragos Stanciu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function parSaveConnectivityMatrix(fileName, connectivity_matrix)
    save(fileName, 'connectivity_matrix');
end
