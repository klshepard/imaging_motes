clc;
close all;

% Configuration for global varialbes
FE_OUTPUT_FILENAME = 'dataframes/invivo_dec_data_frame.mat';

% Take a local snapshot of the maximum values
FE_MAX_EB_N0 = mBeamMaxEbN0;
%FE_MAX_EB_N0 = 0;
FE_DEPTH = mBeamDepth;
%FE_DEPTH = 540;
FE_ELEMENT = mBeamElement;
%FE_ELEMENT = 132;

% Retrive the data point of interest
frame_data = reshape(buffer(FE_DEPTH, FE_ELEMENT * FE_ELEMENT_REPEAT, :), FE_FRAME_SIZE, 1);
plot(frame_data);

% Save it
save(FE_OUTPUT_FILENAME, 'frame_data', 'FE_MAX_EB_N0', 'FE_DEPTH', 'FE_ELEMENT');