function synapse_factor = get_synapse_factor(synapse_diff, synapse_factor, ...
    synapse_coefficient, firing_age)
% TODO: there are two ways of doing this
% 1: compute the mean of the entire synapse_diff
% 2: only compute the mean of the synapse_diff where the corresponding
% synapse_factor is greater than 0
% we implement the 1st situation
% current_diff = synapse_diff(synapse_factor > 0);
if (firing_age > 5)
    current_diff = synapse_diff;
    mean_diff = mean(current_diff);
    lower_thresh = synapse_coefficient(1) * mean_diff;
    upper_thresh = synapse_coefficient(2) * mean_diff;


    % TODO: added in synapse age!
    synapse_factor(synapse_diff > upper_thresh) = 0;

    % TODO: add in grow method
    synapse_factor(synapse_diff <= upper_thresh) = 1./ ... 
        (synapse_diff(synapse_diff <= upper_thresh)+1/(256*sqrt(12))) - ...
        1/(upper_thresh +1/(256*sqrt(12)));
    
    if max(synapse_factor) ~= 0
        synapse_factor = synapse_factor / max(synapse_factor);
    end
end