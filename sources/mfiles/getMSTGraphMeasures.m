%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Loads raw connectivity matrices of chosen connectivity measure and 
%%% computes graph measures on the MSTs (actually maximum spanning tree).
%%%
%%% Script pipeline:
%%% - for each subject
%%%     - for each connectivity matrix of each frequency band, compute MST
%%%     - compute no of leaves, characteristic path length (L), global efficiency (GE),
%%%     avg eccentricity (avgECC), radius, diameter
%%%
%%% Saves feature in:
%%%     [FEATURES_MST_GRAPH]
%%%
%%% Author: Dragos Stanciu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set up global variables
setUpGlobals();
global SET_CS;
global SET_AD;
global SET_MCI;
global FREQ_OF_INTEREST;
global CONNECTIVITY_MATRICES_PATH;
global FEATURES_MST_GRAPH;

% Create directory to store MST features
if ~exist(FEATURES_MST_GRAPH, 'dir')
    mkdir( FEATURES_MST_GRAPH )
end
    
% For each set of subjects
for g = 1:3
    switch g
        case 1
            thisSet = SET_CS;
            groupName = 'CS';
        case 2
            thisSet = SET_MCI;
            groupName = 'MCI';
        case 3
            thisSet = SET_AD;
            groupName = 'AD';
    end

    % For each group, we take every subject
    for i = 1:length(thisSet)

        % For each frequency band of interest (alphabetically)
        for bandIdx = 1 : length(FREQ_OF_INTEREST)
            keySet = keys(FREQ_OF_INTEREST);
            bandName = keySet{bandIdx};

            % Load connectivity matrix
            connMat = load([CONNECTIVITY_MATRICES_PATH thisSet{i} '/' thisSet{i} '_' bandName '_raw.mat'], 'connectivity_matrix');
            connMat = connMat.connectivity_matrix;

            n = size(connMat, 1);    % No of nodes
            
            % Replace diagonal elements with 0 
            connMat(1:n+1:end)=0;
            
            % Replace negative weights with absolute value
            connMat = abs(connMat);

            display([ 'Computing MST for subject ' thisSet{i} ])
            
            % Compute MST
            [mst] = backbone_mst(connMat);
            
            % Compute no of leaves
            deg = degrees_und(mst);
            no_of_leaves = length(deg(deg==1));

            % Compute distance matrix
            distanceMat = distance_bin(mst);
            
            % Compute characteristic path length (L), GE
            [L,GE,ecc,radius,diameter] = charpath_original(distanceMat);
            
            avgECC = mean(ecc);
            
            subjectID = thisSet{i};
            
            save([FEATURES_MST_GRAPH thisSet{i} '_mst_features_' bandName '.mat'], 'no_of_leaves', 'L', 'GE', 'avgECC', 'radius', 'diameter', 'bandName', 'subjectID', 'groupName');
        end
    end
end
