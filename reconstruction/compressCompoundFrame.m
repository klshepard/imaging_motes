clc;
close all;

%% Set a list of source files
%FE_FILES = {'chicken/compound_bmode3_f14p8_span127_bw100.mat';...
%            'chicken/compound_bmode3_f26p6_span127_bw100.mat'};

%FE_FILES = {'chicken/working_bmode_0117_f33p5_span127_bw100.mat';...
%            'chicken/working_bmode_0117_f33p5_span127_bw100.mat'};
FE_FILES = {'invivo/working_bmode_1221_f8_span127_bw100.mat';...
            'invivo/working_bmode_1221_f9_span127_bw100.mat';...
            %'invivo/working_bmode_1221_f10_span127_bw100.mat';...
            'invivo/working_bmode_1221_f10_span127_bw100.mat'};

FE_FOCI = [8e-3, 9e-3, 10e-3]; % [mm]
FE_TRANS = 0.5e-3; % Taper width [mm]

%% Set a target mat file
%FE_OUTPUT_FILE = 'chicken/compound_bmode3_s127_b100.mat';
FE_OUTPUT_FILE = 'chicken/bmode_same_depth_0128_s127_b100.mat';
%FE_OUTPUT_FILE = 'invivo/comp_0123_sp127.mat';

%% Config the movie buffer
FE_BUFFER_SIZE_RAYS = 192;
%FE_BUFFER_SIZE_DEPTH = 1008;
FE_BUFFER_SIZE_DEPTH = 1280;
FE_BUFFER_SIZE_FRAMES = 60;

%% Config the scale factor
FE_SCALE_X = 4; % X
FE_SCALE_Y = 1; % Y
FE_INTENSITY_LIN_SCALE = 2;
FE_INTENSITY_LOG_SCALE = 20;
FE_AGC_LOG_FACTOR = 6;

%% Axis labeling
FE_M_PER_PIXEL_X = 0.2e-3 / FE_SCALE_X;
FE_M_PER_PIXEL_Y = 1.54e3 / 15.625e6 / 2 / FE_SCALE_Y;

FE_AGC_LOG_SCALE = FE_AGC_LOG_FACTOR * FE_M_PER_PIXEL_Y * 1e3;

buffer = zeros(FE_BUFFER_SIZE_DEPTH * FE_SCALE_Y, FE_BUFFER_SIZE_RAYS * FE_SCALE_X, ...
               FE_BUFFER_SIZE_FRAMES);
nr_files = size(FE_FILES, 1);
m_foci = floor(FE_FOCI ./ FE_M_PER_PIXEL_Y);
m_depth = 1 : FE_BUFFER_SIZE_DEPTH;
m_taper = floor(FE_TRANS / FE_M_PER_PIXEL_Y);
weight_windows = taperWeights(m_foci, m_taper, m_depth);

%% Load files
for i_f = 1 : nr_files
    load(FE_FILES{i_f});
    for i = 1 : FE_BUFFER_SIZE_DEPTH
        for j = 1 : FE_BUFFER_SIZE_RAYS
            t_buffer( (i-1) * FE_SCALE_Y + 1 : i * FE_SCALE_Y,...
                      (j-1) * FE_SCALE_X + 1 : j * FE_SCALE_X,...
                      1 : FE_BUFFER_SIZE_FRAMES) = ...
            repmat(target_buffer(i, j, :), [FE_SCALE_Y, FE_SCALE_X]);
        end
    end
    t_weights = repmat(weight_windows(i_f, :)', [1, FE_SCALE_X * FE_BUFFER_SIZE_RAYS]);
    for k = 1 : FE_BUFFER_SIZE_FRAMES
        buffer(:,:,k) = buffer(:,:,k) + t_buffer(:,:,k) .* t_weights;
    end
    clear target_buffer;
end

%% Normalization
% Creating AGC matrix
agc_vector = 1 : FE_AGC_LOG_SCALE : 1 + FE_AGC_LOG_SCALE * (FE_BUFFER_SIZE_DEPTH - 1);
agc_matrix = repmat(agc_vector', 1, FE_BUFFER_SIZE_RAYS * FE_SCALE_X, FE_BUFFER_SIZE_FRAMES);

buffer = buffer ./ max(max(max(buffer)));
%buffer(buffer > 1) = 1;
buffer = logcompression(FE_INTENSITY_LOG_SCALE, buffer);
buffer = buffer .* agc_matrix;
buffer = buffer ./ max(max(max(buffer))) * FE_INTENSITY_LIN_SCALE;

%% Low pass filtering in the horizontal direction
for i = 1 : FE_BUFFER_SIZE_FRAMES
    image_section = buffer(:, :, i);
    image_left = [image_section(:, 1), image_section(:, 1:end-1)];
    image_right = [image_section(:, 2:end), image_section(:, end)];
    buffer(:, :, i) = (image_left + image_right) / 2;
end

save(FE_OUTPUT_FILE, 'buffer', 'FE_M_PER_PIXEL_X', 'FE_M_PER_PIXEL_Y', 'FE_FILES', 'FE_FOCI', 'FE_TRANS');
imshow(buffer(:,:,1));
