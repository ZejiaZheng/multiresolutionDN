function z_output = dn_test(dn, test_image)

dn.x.response = test_image(:)';

% TODO: preprocess data
dn.x.response = preprocess(dn.x.response);

%% compute Y responses
dn.y.bottom_up_response = compute_response(dn.x.response, ...
    dn.y.bottom_up_weight, ...
    dn.y.bottom_up_synapse_factor);

dn.y.pre_lateral_response = dn.y.bottom_up_response;

dn.y.lateral_response = compute_response(dn.y.pre_lateral_response, ...
    dn.y.lateral_weight, ...
    dn.y.lateral_synapse_factor);

dn.y.pre_response = (dn.y.bottom_up_percent * dn.y.pre_lateral_response + ...
    dn.y.lateral_percent * dn.y.lateral_response) / ... 
    (dn.y.bottom_up_percent + dn.y.lateral_percent);

% top-k competition for each neuron
dn.y.response = top_k_competition(dn.y.pre_response, [], dn.y.inhibit_weight, ...
    dn.y.inhibit_synapse_factor, dn.y.top_k);

max_response = max(dn.y.response);
min_response = min(dn.y.response(dn.y.response>0));
if(max_response > min_response)
    dn.y.response = (dn.y.response - min_response + 0.01)/(max_response - min_response + 0.01);
end

%% compute Z response
z_output = zeros(1, dn.z.area_num);
for i = 1:dn.z.area_num
    dn.z.response{i} = compute_response(dn.y.response, dn.z.bottom_up_weight{i}, ...
        ones(size(dn.z.bottom_up_weight{i})));
    [~, z_output(i)] = max(dn.z.response{i});
end