function weights = taperWeights(ranges, taper_width, zvec)
%% taperWeights returns a set of rising-cosine tapered weight vectors for compound reconstruction
%  of ultrasound B-mode images
%  ranges: a set of depths where tapers are centered.
%  taper_width: the width of the taper
%  zvec: the original vector for z domain

nr_weights = size(ranges, 2);
length = size(zvec, 2);
weights = zeros(nr_weights, length);

t_taper_x = 1 : 1 : taper_width;
t_taper_x_low_offset = floor(taper_width / 2);
t_taper_x_high_offset = taper_width - t_taper_x_low_offset;

t_taper_down = (cos(t_taper_x * pi / taper_width) + 1 ) / 2;
t_taper_up = 1 - t_taper_down;

t_range_diff = diff(ranges);
t_separation = zeros(size(t_range_diff));
for i_r = 1 : size(t_range_diff, 2)
    t_separation(i_r) = floor(t_range_diff(i_r) / 2) + ranges(i_r);
end

for i_r = 1 : nr_weights
    if i_r == 1
        t_weight_init = ones(1, t_separation(i_r) - t_taper_x_low_offset);
        t_weight_end = zeros(1, length - t_separation(i_r) - t_taper_x_high_offset);
        weights(i_r, :) = [t_weight_init, t_taper_down, t_weight_end];
        continue;
    end
    if i_r == nr_weights
        t_weight_init = zeros(1, t_separation(i_r-1) - t_taper_x_low_offset);
        t_weight_end = ones(1, length - t_separation(i_r-1) - t_taper_x_high_offset);
        weights(i_r, :) = [t_weight_init, t_taper_up, t_weight_end];
        continue;
    end
    t_weight_init = zeros(1, t_separation(i_r-1) - t_taper_x_low_offset);
    t_weight_mid = ones(1, t_separation(i_r) - t_taper_x_low_offset - t_separation(i_r-1) - t_taper_x_high_offset);
    t_weight_end = zeros(1, length - t_separation(i_r) - t_taper_x_high_offset);
    weights(i_r, :) = [t_weight_init, t_taper_up, t_weight_mid, t_taper_down, t_weight_end];
end

end