%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Gets connectivity matrices by processing all epochs for a subject using
%%% Welch's method.
%%%
%%% Script pipeline: 
%%% - for each epoch, apply Welch's method
%%%     - redefine overlapping minitrials
%%%     - do frequency analysis on minitrials
%%%     - do connectivity analysis on these minitrials with the chosen
%%%     connectivity measure (e.g. dWPLI)
%%%     - average the results over the minitrials to get connectivity matrix 
%%%           for the epoch
%%% - this would result in connectivity matrices for each epoch, which are 
%%%           then averaged to get the connectivity matrix for the subject,
%%%           for the specific frequency band
%%%
%%% Saves connectivity matrices in:
%%%     [CONNECTIVITY_MATRICES_PATH]
%%%
%%% Author: Dragos Stanciu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set up global variables
setUpGlobals();
global Fs;
global EPOCH_LENGTH;
global FILTER_ORDER;
global SET_CS;
global SET_AD;
global SET_MCI;
global CLEANED_EPOCHS_PATH;
global LAYOUT;
global FREQ_OF_INTEREST;
global CONNECTIVITY_MEASURE;
global CONNECTIVITY_MATRICES_PATH;


% Load 'header' variable needed to load data in FieldTrip.
load('../misc/4D_header_adapted.mat');

% For each group of subjects
for g = 1:3
    switch g
        case 1
            thisSet = SET_CS;
        case 2
            thisSet = SET_MCI;
        case 3
            thisSet = SET_AD;
    end
    
    % For each group, we take every subject
    for i = 1:length(thisSet)
        
        % Create directory to save the results for this subject
        if ~exist([ CONNECTIVITY_MATRICES_PATH thisSet{i}], 'dir')
            mkdir( CONNECTIVITY_MATRICES_PATH, thisSet{i} );
        end
        
        % Load epochs for subject
        dirName = [ CLEANED_EPOCHS_PATH thisSet{i} ];
        epochFilesForSubject = getAllFilesInDirectory(dirName);
        noOfEpochs = size(epochFilesForSubject, 1);
           
        %%% Build data structure holding epoch information
        data = [];
        data.label = header.label; 
        data.fsample = Fs;
        
        % Build data.trial and data.time from epochs, with each epoch having its own time vector
        trialsData = cell(1, noOfEpochs);
        timeData = cell(1, noOfEpochs);
        sampleInfo = zeros(noOfEpochs, 2);
        for eachEpoch = 1:noOfEpochs
            epochFile = load(epochFilesForSubject{eachEpoch});
            
            trialsData{1, eachEpoch} = epochFile.meg_no_ecg;  
            timeData{1, eachEpoch} = (0:(EPOCH_LENGTH-1))/169.54;    
            startsample = (epochFile.thisEpoch - 1) * EPOCH_LENGTH + 1; 
            endsample = epochFile.thisEpoch * EPOCH_LENGTH;
            sampleInfo(eachEpoch, 1) = startsample;
            sampleInfo(eachEpoch, 2) = endsample;
        end
        
        data.trial = trialsData;
        data.time = timeData;
        data.sampleinfo = sampleInfo;
        
        %%% end of building data
        
        %%% Constants needed for parallel loop
        no_of_bands = length(FREQ_OF_INTEREST);
        freq_of_interest = FREQ_OF_INTEREST;
        fs = Fs;
        epoch_length = EPOCH_LENGTH;
        filter_order = FILTER_ORDER;
        connectivity_measure = CONNECTIVITY_MEASURE;
        connectivity_matrices_path = CONNECTIVITY_MATRICES_PATH;
        
        % For each frequency band of interest
        parfor bandIdx = 1 : no_of_bands
            keySet = keys(freq_of_interest);
            bandName = keySet{bandIdx};
            
            % Stores the average connectivity matrices for each epoch
            avg_connectivity_per_epoch = [];
            
            % Split each epoch in overlapping segments/trials using Welch method
            for eachEpoch = 1:noOfEpochs
                single_epoch_data = [];
                single_epoch_data.fsample = fs;
                single_epoch_data.label = header.label;
                single_epoch_data.trial{1,1} = data.trial{1,eachEpoch};
                single_epoch_data.time{1,1} = (0:(epoch_length-1))/169.54;
                single_epoch_data.sampleinfo = data.sampleinfo(eachEpoch,:);

                cfg_cut = [];
                cfg_cut.length = 2;        
                cfg_cut.overlap = 0.50100;
                [segmented_minitrials] = ft_redefinetrial(cfg_cut, single_epoch_data); 

                disp('Preprocessing segmented epoch...')

                % Configuration structure for preprocessing the minitrials
                cfg_mini = [];
                cfg_mini.channel = header.label;    % Channels that will be read and/or preprocessed 
                cfg_mini.bpfilter = 'yes';          % Bandpass filter
                % Bandpass frequency range as [low high] in Hz
                cfg_mini.bpfreq = [ freq_of_interest(bandName).low freq_of_interest(bandName).high ];          
                cfg_mini.bpfiltord = filter_order;  % Bandpass filter order 
                cfg_mini.bpfilttype = 'fir';        % Band pass filter type (FIR)
                cfg_mini.bpfiltdir = 'twopass';     % Filter direction - two pass, like filtfilt
                cfg_mini.demean = 'yes';            % Apply baseline correction (remove DC offset)

                % Preprocess the segmented data
                [minitrials_processed] = ft_preprocessing(cfg_mini, segmented_minitrials);

                disp('Computing frequency analysis on preprocessed segmented epoch...')

                % Configuration structure for frequency analysis of an epoch
                cfg_freq = [];
                cfg_freq.method = 'mtmfft';      % Entire spectrum for the entire data length
                if (strcmpi(bandName, 'gamma'))  % Use multitapers for gamma band
                    cfg_freq.taper = 'dpss';
                    cfg_freq.tapsmofrq  = 4;     % +/- 4Hz, i.e. 8Hz smoothing box
                else
                    cfg_freq.taper = 'hanning';
                end
                cfg_freq.foilim=[ freq_of_interest(bandName).low freq_of_interest(bandName).high ];
                cfg_freq.output = 'fourier';   % powandcsd returns the power and the cross-spectra
                cfg_freq.channel = header.label;
                cfg_freq.keeptrial = 'yes';    % Keep minitrials for connectivity analysis

                [single_epoch_freq] = ft_freqanalysis(cfg_freq, minitrials_processed);

                disp('Computing connectivity analysis on processed segmented epoch...')

                % Configuration structure for connectivity for this epoch
                cfg_conn = [];
                % Choose connectivity measure
                switch connectivity_measure
                    case 'dWPLI'
                        cfg_conn.method = 'wpli_debiased';
                    case 'COH'
                        cfg_conn.method = 'coh';
                    case 'ImCOH'
                        cfg_conn.method = 'coh';
                        cfg_conn.complex = 'imag';  % imaginary coherence
                    otherwise
                        error('Unknown connectivity measure.')
                end
                cfg_conn.channel = header.label;
                
                % Resulting connectivity format:channel x channel x frequency
                [single_epoch_conn] = ft_connectivityanalysis(cfg_conn, single_epoch_freq);

                % Append the average connectivity matrices for each epoch
                switch connectivity_measure
                    case 'dWPLI'
                        avg_connectivity_per_epoch = [ avg_connectivity_per_epoch; ...
                            permute(single_epoch_conn.wpli_debiasedspctrm, [4,1,2,3])];
                    case {'COH', 'ImCOH'}
                        avg_connectivity_per_epoch = [ avg_connectivity_per_epoch; ...
                            permute(single_epoch_conn.cohspctrm, [4,1,2,3])];
                end
            end

            disp('Averaging connectivity matrices across epochs...')
            
            % Average connectivity matrices across minitrials
            avg_connectivity_across_minitrials = squeeze(mean(avg_connectivity_per_epoch, 1));
            
            % Replace NaN with zeros (found on main diagonal)
            avg_connectivity_across_minitrials(isnan(avg_connectivity_across_minitrials)) = 0;
            
            % Average connectivity across the frequency spectrum (gives 148x148 matrix)
            connectivity_matrix = mean(avg_connectivity_across_minitrials, 3);
            
            % Put 0s on diagonal as extra check
            connectivity_matrix(1:size(connectivity_matrix,1)+1:end) = 0;
            
            % Save connectivity matrix in folder corresponding to the connectivity measure
            parSaveConnectivityMatrix([connectivity_matrices_path thisSet{i} '/' thisSet{i} '_' bandName '_raw.mat'], connectivity_matrix);
        end
    end  
end
