clc;

%% Control switches
FE_PLOT = 0;
FE_SAVE = 1;

% Number of figures that we need to process;
FE_NR_FIGURES = 8;

% File associated configurations
FE_FOLDER_NAME = 'depth';
FE_DEPTH_MATS = {'depth_5p8';...
                 'depth_10p0';...
                 'depth_15p9';...
                 'depth_20p6';...
                 'depth_25p5';...
                 'depth_30p3';...
                 'depth_34p2';...
                 'depth_39p5'};

% Figure processing options
FE_FIG_X_RANGE = [128, 192];
FE_FIG_Y_RANGE = [1, 1280];
FE_FIG_X_SCALE = 4;
FE_FIG_Y_SCALE = 1;

% Axis labeling
FE_M_PER_PIXEL_X = 0.2e-3 / FE_FIG_X_SCALE;
FE_M_PER_PIXEL_Y = 1.54e3 / 15.625e6 / 2 / FE_FIG_Y_SCALE;

% Span for normalization
FE_NORM_SPAN = 50;

%% Below are recorded values from each experiment
recorded_depths = [5.8, 10.0, 15.9, 20.6, 25.5, 30.3, 34.2, 39.5]; % units in mm
recorded_snr = [25.2, 27.82, 35.94, 31.92, 23.66, 24.1, 23.26, 19.06]; % units in dB
recorded_pressure = [4.5, 6.3, 7.6, 10, 13.6, 27.1, 32.6, 47.6] / 20 * 500; % units in kPa
data_start = [6, 4, 4, 6, 6, 7, 7, 4];


%% Save images to specified folder
s_fig_xrange = FE_FIG_X_RANGE(2) - FE_FIG_X_RANGE(1) + 1;
s_fig_yrange = FE_FIG_Y_RANGE(2) - FE_FIG_Y_RANGE(1) + 1;

if FE_SAVE == 1

    for i = 1:FE_NR_FIGURES
        t_file_name = [FE_FOLDER_NAME, '/', FE_DEPTH_MATS{i}];
        load(t_file_name);
        t_buffer = target_buffer(FE_FIG_Y_RANGE(1): FE_FIG_Y_RANGE(2),...
                                 FE_FIG_X_RANGE(1): FE_FIG_X_RANGE(2));
        t_scaled_buffer = repmat(t_buffer, [FE_FIG_X_SCALE, FE_FIG_Y_SCALE]);
        t_scaled_buffer = reshape(t_scaled_buffer,...
            [s_fig_yrange * FE_FIG_Y_SCALE, s_fig_xrange * FE_FIG_X_SCALE]);

        % Calculate normalization factor
        t_center_y = floor(recorded_depths(i) / FE_M_PER_PIXEL_Y * 1e-3);
        t_max_val = max(max(...
            t_buffer(t_center_y - FE_NORM_SPAN : t_center_y + FE_NORM_SPAN, :)));
        t_scaled_buffer = t_scaled_buffer ./ t_max_val;
        imwrite(t_scaled_buffer, [t_file_name, '.png']);
        clear target_buffer;
    end

end


%% If do plot, then do plot.
if FE_PLOT == 1
    figure;
    plot(recorded_depths, recorded_pressure, 's-');
    hold on
    plot(recorded_depths, repmat([3800], [1,8]));
    axis([0 65 0 4500]);
    xticks(0:5:65);
    xlabel('Distance (mm)');
    ylabel('Source Pressure (kPa)');
    yyaxis right;
    plot(recorded_depths, recorded_snr, 'o-');
    axis([0 65 0 50]);
    ylabel('Signal-to-Noise Ratio (dB)');
end