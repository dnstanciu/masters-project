%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Loads raw connectivity matrices of chosen connectivity measure and
%%% computes graph measures. This constitutes the feature extraction stage 
%%% of the pipeline.
%%%
%%% Script pipeline:
%%% - for each density threshold:
%%%     - for each subject, compute:
%%%         - for each connectivity matrix of each frequency band,
%%%           threshold connectivity matrix by proportion of strongest
%%%           weights (density threshold) (1-all preserved; 0-no edges)
%%%         - compute avg clustering coefficient (C), characteristic path
%%%             length (L), global efficiency (GE), small-worldness (SW), 
%%%             modularity (Q)
%%%      
%%% Saves features in:
%%%     [FEATURES_FULL_GRAPH]/[threshold]
%%%
%%% Author: Dragos Stanciu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set up global variables
setUpGlobals();
global SET_CS;
global SET_AD;
global SET_MCI;
global FREQ_OF_INTEREST;
global CONNECTIVITY_MATRICES_PATH;
global CONNECTIVITY_MEASURE;
global FEATURES_FULL_GRAPH;

% Vector of density thresholds (X% strongest weights)
threshold_vector = [0.05 0.1 0.15 0.2 0.3]; 

% Set parameters needed for small-worldness (SW) values
NO_RAND_GRAPHS = 5;
EDGE_ITER = 50;
%REWIRE_FRACTION = 1;
MODULARITY_ITER = 70;

% For each density threshold
for thresholdIdx = 1:numel(threshold_vector) 
    threshold = threshold_vector(thresholdIdx);
    
    % Create directory to store results for this threshold
    if ~exist([ FEATURES_FULL_GRAPH num2str(threshold) ], 'dir')
        mkdir( FEATURES_FULL_GRAPH, num2str(threshold) )
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
            
            %%% Constants needed for parallel loop
            no_of_bands = length(FREQ_OF_INTEREST);
            freq_of_interest = FREQ_OF_INTEREST;
            connectivity_matrices_path = CONNECTIVITY_MATRICES_PATH;
            connectivity_measure = CONNECTIVITY_MEASURE;
            features_full_graph = FEATURES_FULL_GRAPH;
            % For each frequency band of interest (alphabetically)
            parfor bandIdx = 1 : no_of_bands
                keySet = keys(freq_of_interest);
                bandName = keySet{bandIdx};

                % Load connectivity matrix
                connMat = load([connectivity_matrices_path thisSet{i} '/' thisSet{i} '_' bandName '_raw.mat'], 'connectivity_matrix');
                connMat = connMat.connectivity_matrix;

                n = size(connMat, 1);   % No of nodes
                
                % Replace diagonal elements with 0
                connMat(1:n+1:end)=0;
                
                % Replace negative weights with absolute value
                connMat = abs(connMat);  

                % Threshold matrix (keep X% strongest links)
                connMat = threshold_proportional(connMat, threshold); 

                % Compute average clustering coefficient
                C = mean(clustering_coef_bu(connMat));

                % Compute distance matrix needed for L and GE
                distanceMat = distance_bin(connMat);

                % Compute charact. path length (L) and global efficiency (GE)
                % ignore diagonal and Inf distances (0,0)
                %[L, GE] = charpath(distanceMat, 0, 0);
                [L, GE] = charpath_original(distanceMat);
                
                display(['Computing random graph for subject' thisSet{i} ' band ' bandName ' and threshold ' num2str(threshold)]);

                % Compute random graphs needed for small-worldness (SW) value

                % Create NO_RAND_GRAPHS rand networks from which to extract rand C and L
                holdRandC = zeros(NO_RAND_GRAPHS, 1);
                holdRandL = zeros(NO_RAND_GRAPHS, 1);
                for iteration = 1:NO_RAND_GRAPHS
                    randGraph = randmio_und_connected(connMat, EDGE_ITER);
                    %randGraph = randomizer_bin_und(connMat, REWIRE_FRACTION);
                    holdRandC(iteration) = mean(clustering_coef_bu(randGraph));
                    % Compute distance matrix needed for L
                    randDistanceMat = distance_bin(randGraph);
                    holdRandL(iteration) = charpath(randDistanceMat);
                end

                meanRandC = mean(holdRandC);
                meanRandL = mean(holdRandL);

                % Compute SW ( (C/Crand)/(L/Lrand) )
                SW = (C/meanRandC)/(L/meanRandL);

                holdQVals = zeros(MODULARITY_ITER, 1);
                % Compute and average modularity Q
                for iteration = 1:MODULARITY_ITER
                    [Ci, Qiteration] = modularity_und(connMat);
                    holdQVals(iteration) = Qiteration;
                end

                Q = mean(holdQVals); 

                % Save features for this band (C, L, GE, SW, Q)
                subjectID = thisSet{i};

                parSaveFullGraphMeasures([ features_full_graph num2str(threshold) '/' thisSet{i} '_features_' bandName '.mat'], C, L, GE, SW, Q, threshold, bandName, subjectID, groupName, connectivity_measure);   
            end           
        end
    end
end
