%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load computed MST features from individual files and compiles dataset
%%% type matrices from them.
%%%
%%% Computes ANOVA tests.
%%%
%%% Saves MST features in:
%%%     [DATASETS_MST_GRAPH]
%%%
%%% Author: Dragos Stanciu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Set up global variables
setUpGlobals();
global SET_CS;
global SET_AD;
global SET_MCI;
global DATASETS_MST_GRAPH;
global FREQ_OF_INTEREST;
global NO_OF_MST_GRAPH_MEASURES;
global FEATURES_MST_GRAPH;

% Total no of subjects in study
no_of_subjects = length(SET_CS) + length(SET_MCI) + length(SET_AD);

currentSubjectNo = 0;

% Build dataset .mat
dataset = zeros(no_of_subjects, length(FREQ_OF_INTEREST)*NO_OF_MST_GRAPH_MEASURES+1); % +1 for class
% Build dataset CSV
headers = cell(1, length(FREQ_OF_INTEREST)*NO_OF_MST_GRAPH_MEASURES+1);

% Create directory to store MST dataset
if ~exist( DATASETS_MST_GRAPH, 'dir')
    mkdir( DATASETS_MST_GRAPH )
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

        currentSubjectNo = currentSubjectNo + 1;

        for bandIdx = 1 : length(FREQ_OF_INTEREST) 
        	keySet = keys(FREQ_OF_INTEREST);
            bandName = keySet{bandIdx};

            % Load features
            features = load([FEATURES_MST_GRAPH ...
                    '/' thisSet{i} '_mst_features_' bandName '.mat']);

            % Calculate indices to place band features 
            colBandIdxStart = NO_OF_MST_GRAPH_MEASURES*(bandIdx-1)+1;
            colBandIdxEnd = colBandIdxStart + NO_OF_MST_GRAPH_MEASURES - 1;
            dataset(currentSubjectNo, colBandIdxStart:colBandIdxEnd) = [features.no_of_leaves features.L...
                features.GE features.avgECC features.radius features.diameter]; 

            headers(1, colBandIdxStart:colBandIdxEnd) = {['no_of_leaves', ' ', bandName], ['L', ' ', bandName],...
                            ['GE', ' ', bandName], ['avgECC', ' ', bandName], ['radius', ' ', bandName], ['diameter', ' ', bandName]};
                
        end
        % Set class label for subject
        dataset(currentSubjectNo, end) = g;
        headers(1, end) = {'Class'};
    end
end

%%% Perform ANOVA test to get p-values
% p = [];
% for j=1:size(dataset,2)-1
% 	p = [p anova1(dataset(:,j), dataset(:,end), 'off')];
% end
% plot(p)
% hold all;
% 
% p = p';
% 
% %%% Anova per pairs
% % CS - MCI pair
% pCSMCI=[];
% 
% for j=1:size(dataset,2)-1
%     pCSMCI = [pCSMCI anova1(dataset(1:length(SET_CS)+length(SET_MCI),j), dataset(1:length(SET_CS)+length(SET_MCI), end), 'off')];
% end
% plot(pCSMCI)
% hold all;
% 
% % CS - AD pair
% pCSAD = [];
% CSAD = [dataset(1:length(SET_CS), :) ; dataset(length(SET_CS)+length(SET_MCI)+1:end, :)];
% for j=1:size(CSAD,2)-1
%    pCSAD = [pCSAD anova1(CSAD(:,j), CSAD(:, end), 'off')];
% end
% plot(pCSAD)
% hold all;
% 
% % MCI - AD pair
% pMCIAD = [];
% MCIAD = dataset(length(SET_CS)+1:end, :);
% for j=1:size(MCIAD,2)-1
%     pMCIAD = [pMCIAD anova1(MCIAD(:,j), MCIAD(:, end), 'off')];
% end
% plot(pMCIAD)
% hold all;


% Save dataset of MST features
save([ DATASETS_MST_GRAPH 'datasetMSTGraphMeasures.mat' ], 'dataset');
csvwrite_with_headers([ DATASETS_MST_GRAPH 'datasetMSTGraphMeasures.csv' ], dataset, headers);
