clc;
%clear all;
close all;

%% Load the source data set
%FE_DATA_SET = '../chicken_data/data_11091731_trim.mat';
%FE_DATA_SET = '../chicken_data/data_11091741_trim.mat';
FE_DATA_SET = '../chicken_data/same_depth_a2.mat';
%FE_DATA_SET = '../depth_data/data_11091316.mat';
%FE_DATA_SET = '../invivo_data/data_invivo_2.mat';
% Remember to comment out the latter line, if the data set is already
% loaded
load(FE_DATA_SET);
rawData = RcvData{1};

%% Set the load data target folder
%FE_TARGET_FOLDER = 'invivo';
FE_TARGET_FOLDER = 'chicken';
%FE_TARGET_FILE = 'working_bmode_1221_f8_span127_bw100.mat';
FE_TARGET_FILE = 'working_bmode_0125a2_f29p5_span127_bw100.mat';

if ~isfolder(FE_TARGET_FOLDER)
    mkdir(FE_TARGET_FOLDER);
end

%% Set the constant
% Physical
FE_SPEED_OF_SOUND = 1.54e3; % m/s
FE_SAMPS_PER_SEC = 15.625e6; % samps/s
FE_SPACING = 0.2e-3; % m
FE_CENTER_FREQ = 4.0323e6; % Hz

% Program specification
FE_RANGE = [1, 1280]; % Start-End sample number
FE_NR_RAYS = 192;

% Delay-and-Sum range
FE_DAS_CENTER = 0;
FE_DAS_SPAN = 127;

% Filter bandwidth
FE_FILTER_BW = 100;

% Image normalization parameter
FE_IMAGE_MAX_VAL = 255;
% These two sums to be 272
%FE_INITIAL_IMAGE_CROP = 25;
%FE_END_IMAGE_CROP = 247;
FE_INITIAL_IMAGE_CROP = 0;
FE_END_IMAGE_CROP = 0;

%% Reconstruction focus.
%  Basically a receive focusing
FE_FOCUS = 29.5e-3; % m
%FE_FOCUS = 14.8e-3; % m, empirical
%FE_FOCUS = 11e-3; % m, empirical
%FE_FOCUS = 8e-3;

%% Assemble the target buffer
nr_frames = size(rawData, 3);
target_buffer = zeros(FE_RANGE(2) - FE_RANGE(1) + 1 - FE_INITIAL_IMAGE_CROP - FE_END_IMAGE_CROP,...
                      FE_NR_RAYS, nr_frames);
        
%% Assemble the range of the delay and sum
FE_DAS_RANGE = FE_DAS_CENTER - (FE_DAS_SPAN - 1) / 2 : 1 : FE_DAS_CENTER + (FE_DAS_SPAN - 1) / 2;

for nr_frame = 1 : nr_frames
    %% Call the delay and sum script
    bmode_frame = delayAndSum(rawData(:, : ,nr_frame), FE_SPEED_OF_SOUND,...
                              FE_SAMPS_PER_SEC, FE_RANGE, FE_NR_RAYS, FE_FOCUS,...
                              FE_SPACING, FE_DAS_RANGE);
    % Sum and permutation
    summed_frame = permute(sum(bmode_frame, 2), [3 1 2]);

    % Filter and envelope detection
    filtered_frame = gaussianFilter2(summed_frame, FE_SAMPS_PER_SEC,...
                                     FE_CENTER_FREQ, FE_FILTER_BW);
    clean_frame = envelopeDetection(filtered_frame)';
    crop_frame = clean_frame(FE_INITIAL_IMAGE_CROP + 1 : end - FE_END_IMAGE_CROP, :);

    % Normalization
    final_frame = crop_frame ./ max(max(crop_frame)) * FE_IMAGE_MAX_VAL;

    target_buffer(:, :, nr_frame) = final_frame;
    
    disp(['Process done for frame number ', num2str(nr_frame)]);
end

save([FE_TARGET_FOLDER, '/', FE_TARGET_FILE], 'target_buffer', 'FE_FOCUS', 'FE_DAS_SPAN', 'FE_FILTER_BW');

