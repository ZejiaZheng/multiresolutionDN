function response_output = top_k_competition(response_input, top_down_response, inhibit_weight, ...
    inhibit_synapse_factor, top_k)

% TODO : there are two ways to do things
% 1: if a neuron is within the synapse, then include that neuron in top-k
% 2: if a neuron is within the synapse and the weight is > 0.5, then
% include that neuron in top-k
% this version does things in the 1st way

% response_input is of size 1 x neuron_num

response_output = zeros(size(response_input));
neuron_num = numel(response_input);

for i = 1: neuron_num
    curr_response = response_input(i);
    curr_mask = (inhibit_synapse_factor(:, i) > 0)';
    compare_response = response_input .* curr_mask; 
    compare_response(i) = curr_response;
    [~, neuron_id] = sort(compare_response, 'descend');
    
    for j = 1:top_k
        if size(top_down_response, 1) ~= 0
            if neuron_id(j) == i && top_down_response(i)>0            
               response_output(i) = 1;
               break;
            end
        else if neuron_id(j) == i
                response_output(i) = 1;
                break;
            end
        end
    end
end

