%% beautify_frame:
%  Super samples the frame's data in time domain, to make the plot look
%  nicer.
function [retf, retd] = beautify_frame(frame, data)
    nr_frames = size(frame, 2);
    up_sampler = 10;
    resolution = 1/up_sampler;
    retf = resolution : resolution : nr_frames;
    retd = repmat(data - mean(data(40:end)), [up_sampler, 1]);
    retd = reshape(retd, [1, up_sampler * nr_frames]);
    if (min(retd) < -0/256)
        retd = -retd;
    end
end