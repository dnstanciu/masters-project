%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This sets up the global variables to be used by the analysis scripts.
%%%
%%% List of subjects taken from set_up_noECG_noFilt() function by Javier Escudero.
%%%
%%% Author: Dragos Stanciu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function setUpGlobals()

clear;

% Seed the random number generator for repeatable results
rng(20);

% Add folder with utility scripts to search path
addpath('./utils')

% Sampling frequency in Hz
global Fs;
Fs = 169.54;

% Epoch length in seconds
global EPOCH_TIME;
EPOCH_TIME = 10;
% Epoch length in time samples
global EPOCH_LENGTH; 
EPOCH_LENGTH = floor(EPOCH_TIME*Fs);

% FIR filter order
global FILTER_ORDER;
FILTER_ORDER = 560;


%%% The 80 subjects of this study: control, AD & MCI.

% Whole list of control subjects
global SET_CS;
SET_CS = {
      'DCOG15';
      '44'; 
      '35';
      'AL38';
      'DCOG35';
      '36';
      'DCOG25';
      'AL35C';
      'AL23C';
      'DCOG26';
      'DCOG21';
      'DCOG12';
      'AL32C';
      '38'; 
      'DCOG24';
      'AL44C';
      'AL42';
      '08';
      '09bis';
      '43';
      'AL17C';
      'CONT38C';
      'AL33C';
      '07';
      'DCOG23';
      'AL43C';
      };

% Whole list of Alzheimer's Disease (AD) patients
global SET_AD;
SET_AD = {
      '21'; 
      '28';
      '30';
      '40'; 
      '41'; 
      '42'; 
      '27'; 
      '34'; 
      'AL15';
      'DCOG01';
      'DCOG04';
      'DCOG22';
      'DCOG29';
      'DCOG34';
      'DCOG39';
      'MUTUA07A';
      'MUTUA09A';
      'MUTUA13A';
      'MUTUA15A';
      'DCOG49D';
      'AL01A';
      'AL04A';
      'AL05A';
      'AL08A';
      'AL18A';
      'AL19A';
      'AL20A';
      'AL22A';
      'AL24A';
      'AL25A';
      'AL26A';
      'AL28A';
      'AL30A';
      'AL31A';
      'AL36A';
      'DCOG38A';
      };

% Whole list of Mild Cognitive Impairment (MCI) patients
global SET_MCI;
SET_MCI = {
      'DCOG30D';
      'MUTUA01D';
      'AL39D';
      '37';
      'DCOG09D';
      'DCOG16D';
      'DCOG02D';
      'DCOG06D';
      'MUTUA51D';
      'DCOG08D';
      'MUTUA12D';
      'MUTUA19D';
      'MUTUA33D';
      'AL41D';
      'MUTUA20D';
      'MUTUA52D';
      'MUTUA54D';
      'DCOG07D';
      };

% Path of the MEG recordings
global RAW_MEG_PATH;
RAW_MEG_PATH = '/home/dragos/Projects/SummerProject/data/MEG_AD_Thesis/50863/';

% Path to saved cleaned epochs
global CLEANED_EPOCHS_PATH;
CLEANED_EPOCHS_PATH = '/home/dragos/Projects/SummerProject/data/MEG_AD_Thesis/MEG_50863_noECG_10s/';

% Set of MEG channels to be considered in the study.
global ALL_CHANNELS;
ALL_CHANNELS = 1:148;

% Location of layout file used for FieldTrip connectivity plots.
global LAYOUT;
LAYOUT = '../misc/4D148.lay';

% Store frequencies of interest (Hz) in a map (each row is a band of interest)
bands = { 'delta', 'theta', 'alpha', 'beta', 'gamma' };
delta.low = 0.5; delta.high = 4;
theta.low = 4; theta.high = 8;
alpha.low = 8; alpha.high = 13;
beta.low = 13; beta.high = 30;
gamma.low = 30; gamma.high = 45;

global FREQ_OF_INTEREST;
FREQ_OF_INTEREST = containers.Map( bands, {delta, theta, alpha, beta, gamma} );

global NO_OF_FULL_GRAPH_MEASURES;
NO_OF_FULL_GRAPH_MEASURES = 5;

global NO_OF_MST_GRAPH_MEASURES;
NO_OF_MST_GRAPH_MEASURES = 6;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Path to (root) directory holding output of scripts.
% TODO: change this to your requirements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global ROOT_PROCESSED_DATA;
ROOT_PROCESSED_DATA = '../../processed_data/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Chosen connectivity measure from available connectivity measures. 
% 
% Available measures:
%   - dWPLI  (debiased weighted phase lag index)
%   - COH    (coherence)
%   - ImCOH  (imaginary part of coherence)
%
% TODO: change this as required
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global CONNECTIVITY_MEASURE;
CONNECTIVITY_MEASURE = 'dWPLI';

% Check that chosen measure is available in getConnectivityMatrices.m.
switch CONNECTIVITY_MEASURE
    case {'dWPLI', 'COH', 'ImCOH'}
    otherwise
        error(['Unknown specified connectivity measure: ' CONNECTIVITY_MEASURE])
end

% Build path to save connectivity matrices depending on chosen measure
global CONNECTIVITY_MATRICES_PATH;
CONNECTIVITY_MATRICES_PATH = [ROOT_PROCESSED_DATA 'connectivity_matrices/'];
CONNECTIVITY_MATRICES_PATH = [CONNECTIVITY_MATRICES_PATH CONNECTIVITY_MEASURE '/'];

% Path to directory holding computed features (graph measures). 
FEATURES_ROOT = [ROOT_PROCESSED_DATA 'features/'];

% Build path to save graph measures of full connectivity graphs
global FEATURES_FULL_GRAPH;
FEATURES_FULL_GRAPH = [FEATURES_ROOT CONNECTIVITY_MEASURE '/full_graph/'];

% Build path to save graph measures of minimum spanning tree (MST) graphs
global FEATURES_MST_GRAPH;
FEATURES_MST_GRAPH = [FEATURES_ROOT CONNECTIVITY_MEASURE '/mst/'];

% Build path to save dataset of graph measures of full connectivity graphs
global DATASETS_FULL_GRAPH;
DATASETS_FULL_GRAPH = [FEATURES_FULL_GRAPH 'datasets/'];

% Build path to save dataset of graph measures of MST graphs
global DATASETS_MST_GRAPH;
DATASETS_MST_GRAPH = [FEATURES_MST_GRAPH 'datasets/'];

end
