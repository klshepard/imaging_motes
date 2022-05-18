%% Make Movie
% This file compiles a sequence of frames into an MP4 movie.
% The only modification of this script remains in the time scale, which
% means that this script can slow down the progression of the movie by
% artificially extending each frame by a factor called FE_TIME_SCALE

clc;
close all;

%% Set the source files
%FE_FILE_NAME = 'invivo/comp_0429.mat';
FE_FILE_NAME = 'invivo/comp_1221_sp127.mat';
%FE_FILE_NAME = 'chicken/bmode_same_depth_s127_b100.mat';

% Load this source file
load(FE_FILE_NAME);

%% Set the name of the source buffer
%proc_buffer = buffer;
%proc_buffer = final_buffer;
%proc_buffer = target_buffer;
proc_buffer = all_zoomed_buffer;

%% Set if we want a scale bar
FE_HAS_SCALE_BAR = 0;

%% Set the output video target
%FE_TARGET_FOLDER = 'precompiles/chicken_jan/orig/';
FE_TARGET_FOLDER = 'precompiles/invivo_dec_final/zoom/img';

%% Video cropping and scaling
FE_XCROP = [1, 192 * 4];
%FE_XCROP = [99 * 4 + 1, 107 * 4];
%FE_XCROP = [127*4+1, 170*4];
%FE_XCROP = [1+16*4, 176*4];
%FE_XCROP = [1, 256];
FE_YCROP = [1, 1280];
%FE_YCROP = [1, 720];
%FE_YCROP = [168, 199];
%FE_YCROP = [1+32, 272];
FE_TIME_SCALE = 10;
%FE_TIME_SCALE = 1;

%% Configure scale bar related settings
if FE_HAS_SCALE_BAR
    FE_SCALE_BAR_X = 50;
    FE_SCALE_BAR_Y = 700;
    FE_ACTUAL_LENGTH = 5e-3;
    FE_SCALE_BAR_W = 2;
    FE_SCALE_BAR_L = FE_ACTUAL_LENGTH / FE_M_PER_PIXEL_X;
end

%% Initialize and fill the final buffer
final_buffer = proc_buffer(FE_YCROP(1) : FE_YCROP(2), FE_XCROP(1) : FE_XCROP(2), :);
if FE_HAS_SCALE_BAR
    final_buffer(FE_SCALE_BAR_Y : FE_SCALE_BAR_Y + FE_SCALE_BAR_W - 1,...
                 FE_SCALE_BAR_X : FE_SCALE_BAR_X + FE_SCALE_BAR_L - 1, :) = 1;
end
nr_frame_index = size(final_buffer, 3);

max_string_length = size(num2str(nr_frame_index * FE_TIME_SCALE), 2);

for i = 1 : nr_frame_index
    for j = 1 : FE_TIME_SCALE
        index_str = num2str((i-1) * FE_TIME_SCALE + j);
        while size(index_str, 2) < max_string_length
            index_str = ['0', index_str];
        end
        imwrite(final_buffer(:, :, i), [FE_TARGET_FOLDER, index_str, '.png'], 'PNG');
    end
end