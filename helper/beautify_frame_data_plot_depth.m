clc;
close all;

% This is the plot for the idealized intensity changes
FE_FILE = 'dataframes/depth_data_frame_noise.mat';

FE_DATA = [0,0, 0,1,0,1, 1,1,1,1, 1,1,1,1, 0,1];
FE_DATA_START = 6;
FE_FRAME_SIZE = 60;

codeVerifyRange = size(FE_DATA,2);
FE_CODE_EXTEND = [ones(1,FE_DATA_START), ...
    reshape([FE_DATA;ones(1,codeVerifyRange)],1,codeVerifyRange*2), ...
    ones(1, FE_FRAME_SIZE - codeVerifyRange*2 - FE_DATA_START)];
            
frames = 1:FE_FRAME_SIZE;

% Load the file
load(FE_FILE);

t_ones = mean(frame_data(40:end)) - frame_data(FE_CODE_EXTEND == 1);
t_zeros = mean(frame_data(40:end)) - frame_data(FE_CODE_EXTEND == 0);
t_mean_ones = mean(t_ones) * 256;
t_mean_zeros = mean(t_zeros) * 256;

t_var_ones = std(t_ones * 256);
t_var_zeros = std(t_zeros * 256);

t_mean_ones = ones(1, FE_FRAME_SIZE * 10) * t_mean_ones;
t_max_ones = t_mean_ones + t_var_ones;
t_min_ones = t_mean_ones - t_var_ones;

t_mean_zeros = ones(1, FE_FRAME_SIZE * 10) * t_mean_zeros;
t_max_zeros = t_mean_zeros + t_var_zeros;
t_min_zeros = t_mean_zeros - t_var_zeros;

[plot_frame, plot_data] = beautify_frame(frames, frame_data');
plot_data = plot_data * 256;
figure;
plot(plot_frame, plot_data);
%hold on;
%plot(plot_frame, t_mean_ones);
%plot(plot_frame, t_max_ones);
%plot(plot_frame, t_min_ones);
%plot(plot_frame, t_mean_zeros);
%plot(plot_frame, t_max_zeros);
%plot(plot_frame, t_min_zeros);
axis([0 FE_FRAME_SIZE -0.3 1.5]);