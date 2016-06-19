function output_vec = compute_response(input_vec, weight_vec, synapse_factor)

% input_vec is of shape 1x input_dim
% weight_vec is of shape input_dim x neuron_num
% syanpse_factor is of shape input_dim x neuron_num

neuron_num = size(weight_vec, 2);
temp_input = repmat(input_vec, [neuron_num, 1]);
temp_input = temp_input .* synapse_factor;
temp_input_norm = sqrt(sum(temp_input.^2, 2));
temp_input_norm(temp_input_norm == 0) = 1;

temp_input = temp_input ./ repmat(temp_input_norm, [1, neuron_num]);


weight_vec_normalized = weight_vec .* synapse_factor;
weight_vec_norm = sqrt(sum(weight_vec_normalized.^2, 2));
weight_vec_norm(weight_vec_norm == 0) = 1;

weight_vec_normalized = weight_vec_normalized ./ ...
    repmat(weight_vec_norm, [1, neuron_num]);

output_vec = temp_input * weight_vec_normalized;
