clc;
close all;

%% Set a list of source files
%FE_FILE_HEADER = 'chicken/exnarrow_';
FE_FILE_NAMES = {'chicken/compound_bmode1_s127_b100.mat'; ...
                 'chicken/compound_bmode2_s127_b100.mat'; ...
                 'chicken/compound_bmode3_s127_b100.mat'};

%% Set a target mat file
FE_OUTPUT_FILE = 'chicken/compound_s127_b100_all.mat';
%FE_OUTPUT_FILE = 'invivo/working_0422_f11_span127_bw100.mat';

%% Config the movie buffer
FE_BUFFER_SIZE_RAYS = 192;
%FE_BUFFER_SIZE_DEPTH = 1008;
FE_BUFFER_SIZE_DEPTH = 1280;
FE_BUFFER_SIZE_FRAMES = 60;

%% Config the scale factor
FE_SCALE_X = 4; % X
FE_SCALE_Y = 1; % Y
FE_INTENSITY_SCALE = 5;

%% Axis labeling
FE_M_PER_PIXEL_X = 0.2e-3 / FE_SCALE_X;
FE_M_PER_PIXEL_Y = 1.54e3 / 15.625e6 / 2 / FE_SCALE_Y;

nr_files = size(FE_FILE_NAMES, 1);

concat_buffer = zeros(FE_BUFFER_SIZE_DEPTH * FE_SCALE_Y, FE_BUFFER_SIZE_RAYS * FE_SCALE_X, ...
               FE_BUFFER_SIZE_FRAMES * nr_files);


%% Load files
for i_f = 1 : nr_files
    file_name = FE_FILE_NAMES{i_f};
    load(file_name);
    concat_buffer( :, :, ...
                   1 + (i_f - 1) * FE_BUFFER_SIZE_FRAMES : i_f * FE_BUFFER_SIZE_FRAMES) = ...
                   buffer(:, :, :);
    clear buffer;
end

buffer = concat_buffer;

save(FE_OUTPUT_FILE, 'buffer', 'FE_M_PER_PIXEL_X', 'FE_M_PER_PIXEL_Y');