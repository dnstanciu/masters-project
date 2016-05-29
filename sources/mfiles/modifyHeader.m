%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This script modifies the 4D_header.mat file from Ricardo
%%% so it matches the details of the MEG machine used for collecting our data.
%%%
%%% This header is needed for loading the data in FieldTrip.
%%%
%%% Author: Dragos Stanciu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load original header file
header = load('../misc/4D_header_original.mat');

% Rename cells to A1, A2, ... A148
myChannelLabels = header.header.label(1:148);

for i=1:length(myChannelLabels)
    myChannelLabels{i} = strcat('A',num2str(i));
end

header.header.label = myChannelLabels;

% Change number of channels to 148
header.header.nChans = 148;

% Change number of samples to 1695
header.header.nSamples = 1695;

% Shrink chantype to 148 items 
myChannelTypes = header.header.chantype(1:148);
for i=1:length(myChannelTypes)
    myChannelTypes{i} = 'meg';
end

header.label=cellfun(@(x)strcat('A',strtrim(x)),cellstr(num2str([1:header.header.nChans]')),'UniformOutput',false);
header.header.chantype = myChannelTypes;

% Shrink chanunit to 148 items 
myChannelUnits = header.header.chanunit(1:148);
for i=1:length(myChannelUnits)
    myChannelUnits{i} = 'T';
end

header.header.chanunit = myChannelUnits;

% Change sampling frequency to 169.54
header.header.Fs = 169.54;

% Save the new header file to the disk.
save('../misc/4D_header_adapted.mat', 'header');
