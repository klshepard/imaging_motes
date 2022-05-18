clc;
close all;

% These are the files for the chicken plot
% FE_FILE_LIST = {'dataframes/chicken_data_frame1_ff.mat';
%                 'dataframes/chicken_data_frame1_fe.mat';
%                 'dataframes/chicken_data_frame2_ff.mat';
%                 'dataframes/chicken_data_frame2_fe.mat';
%                 'dataframes/chicken_data_frame3_ff.mat';
%                 'dataframes/chicken_data_frame3_fe.mat';
%                 'dataframes/invivo_data_frame.mat'};

% This is the plot for the idealized intensity changes
FE_FILE_LIST = {'dataframes/invivo_dec_data_frame.mat'};
            
frames = 1:60;
nr_files = size(FE_FILE_LIST, 1);

for i = 1 : nr_files
    FE_FILE = FE_FILE_LIST{i};
    load(FE_FILE);
    [plot_frame, plot_data] = beautify_frame(frames, frame_data');
    plot_data = -plot_data * 256;
    figure;
    plot(plot_frame, plot_data);
    axis([0 60 -1 3]);
end