clc;
close all;

%% Configure the source of the buffer
%temp_buffer = final_buffer(:,:,1:60);
all_proc_buffer = buffer(:, :, :);
all_zoomed_buffer = zeros(size(all_proc_buffer));

%% Configure the frame separation scheme
FE_SUB_FRAME_SIZE = 60;

%% Pre-processing
total_frames = size(all_proc_buffer, 3);
nr_sub_frames = total_frames / FE_SUB_FRAME_SIZE;

%% Process: substract the mean of each frame, and then take the absolute value of it.
for i = 1:nr_sub_frames
    proc_buffer = all_proc_buffer(:, :, (i - 1) * FE_SUB_FRAME_SIZE + 1 : i * FE_SUB_FRAME_SIZE);
    proc_buffer = permute(proc_buffer, [3, 1, 2]);
    mean_value = mean(proc_buffer, 1);
    mean_value = repmat(mean_value, [FE_SUB_FRAME_SIZE, 1, 1]);
    proc_buffer = proc_buffer - mean_value;

    % Abs and normalization
    zoomed_buffer = abs(proc_buffer);
    zoomed_buffer = permute(zoomed_buffer, [2, 3, 1]);
    zoomed_buffer = zoomed_buffer ./ max(max(max(zoomed_buffer)));
    all_zoomed_buffer(:, :, (i - 1) * FE_SUB_FRAME_SIZE + 1 : i * FE_SUB_FRAME_SIZE) = zoomed_buffer;
end
