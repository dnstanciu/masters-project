%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Loads computed graph features from indidivual files and compiles dataset
%%% type matrices from them.
%%%
%%%	Measures:
%%%        avg clustering coefficient (C), characteristic path
%%%        length (L), global efficiency (GE), small-worldness (SW), 
%%%        modularity (Q)
%%%
%%%  Structure of row in dataset: [C L GE SW Q Y]
%%%  where SUBJECTID is the name of the subject and    
%%%  Y is the class label: 1 for CS, 2 for MCI, 3 for AD patients.
%%%
%%%  Save features in:
%%%     [DATASETS_FULL_GRAPH]/[threshold]
%%%
%%% Author: Dragos Stanciu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set up global variables
setUpGlobals();
global SET_CS;
global SET_AD;
global SET_MCI;
global DATASETS_FULL_GRAPH;
global FREQ_OF_INTEREST;
global NO_OF_FULL_GRAPH_MEASURES;
global FEATURES_FULL_GRAPH;
global CONNECTIVITY_MEASURE;


% Vector of density thresholds (X% strongest weights)
threshold_vector = [0.05 0.1 0.15 0.2 0.3]; 

% Total no of subjects in study
no_of_subjects = length(SET_CS) + length(SET_MCI) + length(SET_AD);

% For each density threshold
for thresholdIdx = 1:numel(threshold_vector) 
    threshold = threshold_vector(thresholdIdx); % the actual threshold
    
    % Create directory to store dataset for this threshold
    if ~exist([ DATASETS_FULL_GRAPH num2str(threshold) ], 'dir')
        mkdir( DATASETS_FULL_GRAPH, num2str(threshold) )
    end
    
    currentSubjectNo = 0;
    
    % Build dataset .mat
    dataset = zeros(no_of_subjects, length(FREQ_OF_INTEREST)*NO_OF_FULL_GRAPH_MEASURES+1);  % +1 for class label
    % Build dataset CSV
    headers = cell(1, length(FREQ_OF_INTEREST)*NO_OF_FULL_GRAPH_MEASURES+1);
    
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

            currentSubjectNo = currentSubjectNo + 1;
    
            % For each frequency band of interest
            for bandIdx = 1 : length(FREQ_OF_INTEREST) 
                keySet = keys(FREQ_OF_INTEREST);
                bandName = keySet{bandIdx};

                % Load features
                features = load([FEATURES_FULL_GRAPH num2str(threshold) ...
                        '/' thisSet{i} '_features_' bandName '.mat']);

                % Calculate indices to place band features 
                colBandIdxStart = NO_OF_FULL_GRAPH_MEASURES*(bandIdx-1)+1;
                colBandIdxEnd = colBandIdxStart + NO_OF_FULL_GRAPH_MEASURES - 1;
                dataset(currentSubjectNo, colBandIdxStart:colBandIdxEnd) = [features.C features.L...
                    features.GE features.SW features.Q];
                headers(1, colBandIdxStart:colBandIdxEnd) = {['C', ' ',bandName], ['L', ' ', bandName],...
                                ['GE', ' ', bandName], ['SW', ' ', bandName], ['Q', ' ', bandName]};
                    
            end
            % Set class label for subject
            dataset(currentSubjectNo, end) = g;
            headers(1, end) = {'Class'};
        end
    end
    
    
    %%% Can also do ANOVA instead of FDA in Python notebook to get p-values
    % p = [];
    % for j=1:size(dataset,2)-1
    %     p = [p anova1(dataset(:,j), dataset(:,end), 'off')];
    % end
    % plot(p)
    % hold all;
    
    % Save dataset for this threshold 
    save([ DATASETS_FULL_GRAPH num2str(threshold) '/datasetFullGraphMeasures.mat' ], ...
                    'dataset', 'threshold', 'CONNECTIVITY_MEASURE');
    csvwrite_with_headers([ DATASETS_FULL_GRAPH num2str(threshold) ...
                '/datasetFullGraphMeasures.csv' ], dataset, headers);
end
