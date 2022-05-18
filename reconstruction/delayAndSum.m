function image_data = delayAndSum(raw_data, speed_of_sound,...
                                  sample_rate, sample_range, nr_rays,...
                                  focal_depth, element_spacing, subset_range)

g_m_per_sample = speed_of_sound / sample_rate;

end_samp = sample_range(2);
start_samp = sample_range(1);

% Extract the total number of receive channels
nr_receive = size(raw_data, 2);
nr_process = size(subset_range, 2);

% Initialization of the aligned raw value buffer
aligned_raw = zeros(end_samp - start_samp + 1, nr_process, nr_rays);

% Phasing
for nr_ray = 1 : nr_rays
    
    % Assemble the delay list
    % Verasonics uses the nr_ray element as the center element, if nr_rays
    % = 192
    dist_hori = ((1 : nr_rays) - nr_ray) * element_spacing;
    dist_abs = sqrt(dist_hori .^ 2 + focal_depth .^2);
    delay_in_sample = double(int16(dist_abs / g_m_per_sample)); % In number of samples
    delay_list = zeros(nr_receive, 1);
    
    % Since Verasonics rolls the data, the actual construction of the
    % receive delay list needs to fall into three different categories.
    if nr_ray > nr_receive
        delay_list(nr_ray - nr_receive : nr_receive) = delay_in_sample(nr_ray - nr_receive : nr_receive);
        delay_list(1 : nr_receive / 2) = delay_in_sample(end - nr_receive / 2 + 1 : end);
    elseif nr_ray > nr_receive / 2
        delay_list(1 : nr_ray - nr_receive / 2) = delay_in_sample(nr_receive + 1 : nr_receive / 2 + nr_ray);
        delay_list(nr_ray - nr_receive / 2 + 1 : end) = delay_in_sample(nr_ray - nr_receive / 2 + 1 : nr_receive);
    else
        delay_list = delay_in_sample(1 : nr_receive);
    end
    
    % This is where the margin in the max_delay comes from
    delay_list = delay_list - min(delay_list);
    
    % Assemble the element range
    element_range = subset_range + nr_ray;
    element_range = element_range(element_range > 0);
    element_range(element_range > nr_receive) = element_range(element_range > nr_receive) - nr_receive;
    
    % Advance the receive buffer according to each delay value of the
    % element, and zero-padding the remaining.
    for nr_element = element_range
        aligned_raw(:, nr_element, nr_ray) = [raw_data(...
            1 + (nr_ray - 1) * end_samp + delay_list(nr_element) : nr_ray * end_samp,...
            nr_element);...
            zeros(delay_list(nr_element), 1)];
    end
    image_data = aligned_raw;
end

end