function synapse_factor = get_synapse_factor(synapse_diff, synapse_factor, ...
    synapse_coefficient)
% TODO: there are two ways of doing this
% 1: compute the mean of the entire synapse_diff
% 2: only compute the mean of the synapse_diff where the corresponding
% synapse_factor is greater than 0
% we implement the 1st situation

%current_diff = synapse_diff(synapse_factor > 0);
current_diff = synapse_diff;
mean_diff = mean(current_diff);
lower_thresh = synapse_coefficient(1) * mean_diff;
upper_thresh = synapse_coefficient(2) * mean_diff;


% TODO: added in synapse age!
% cannot cut synapse too quickly, cut coefficient(3) connections at a time
% [temp_diff, order] = sort(synapse_diff .* synapse_factor, 'descend');
% if(temp_diff(order(synapse_coefficient(3)+1)) > upper_thresh)
%     upper_thresh = temp_diff(order(synapse_coefficient(3)+1));
% end
synapse_factor(synapse_diff > upper_thresh) = 0;
synapse_factor(synapse_diff < lower_thresh) = 1;

% TODO: add in grow method
synapse_factor(((synapse_diff <= upper_thresh).* (synapse_diff >= lower_thresh)) == 1) = ...
    (synapse_diff(((synapse_diff <= upper_thresh).* (synapse_diff >= lower_thresh) == 1)) - upper_thresh)/...
    (lower_thresh - upper_thresh);
