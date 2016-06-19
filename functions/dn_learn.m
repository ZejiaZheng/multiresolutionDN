function dn = dn_learn(dn, training_image, true_z)

dn.x.response = training_image(:);
for i = 1:dn.z.area_num
    dn.z.response{i} = zeros(size(dn.z.response{i}));
    dn.z.response{i}(true_z(i)) = 1;
end

% TODO: preprocess data

%% compute responses
dn.y.bottom_up_response = compute_response(dn.x.response, ...
    dn.y.bottom_up_weight, ...
    dn.y.bottom_up_synapse_factor);
for i = 1:dn.z.area_num
    dn.y.top_down_response(i, :) = compute_response(dn.z.response{i}, ...
        dn.y.top_down_weight, ...
        dn.y.top_down_synapse_factor);
end

dn.y.pre_lateral_response = (dn.y.bottom_up_percent* dn.y.bottom_up_response + ...
    dn.y.top_down_percent* mean(dn.y.top_down_response, 1)) / ...
    (dn.y.bottom_up_percent + dn.y.top_down_percent);

dn.y.lateral_response = compute_response(dn.y.pre_lateral_response, ...
    dn.y.lateral_weight, ...
    dn.y.lateral_syanpse_factor);
dn.y.pre_response = (dn.y.bottom_up_percent + dn.y.top_down_percent) * ...
    dn.y.pre_lateral_response + dn.y.lateral_percent * ...
    dn.y.lateral_response;

% top-k competition for each neuron
dn.y.response = top_k_competition(dn.y.pre_response, dn.y.inhibit_weight, ...
    dn.y.inhibit_synapse_factor);


%% hebbian learning and synapse maitenance
for i = 1: dn.y.neuron_num    
    if dn.y.response(i) == 1  % firing neuron, currently set response to 1
        dn.y.lsn_flag(i) = 1;
        lr = get_learning_rate(dn.y.firing_age(i)); % learning rate
        
        % TODO: check if we want to use y_bottom_up input instead of x
        % response to to weight update, namely, do we need to 
        
        % bottom-up weight and synapse factor
        dn.y.bottom_up_weight(:, i) = (1-lr) * dn.y.bottom_up_weight(:, i) + ...
            lr * dn.x.response';
        dn.y.bottom_up_synapse_diff(:,i) = (1-lr) * dn.y.bottom_up_synapse_diff(:, i) + ...
            lr * abs(dn.y.bottom_up_weight(:, i) - dn.x.response');
        dn.y.bottom_up_synapse_factor(:, i) = get_synapse_factor(...
            dn.y.bottom_up_synapse_diff(:,i));
        
        % top-down weight and synapse factor
        for j = 1:dn.z.area_num
            dn.y.top_down_weight{j}(:, i) = (1-lr) * dn.y.top_down_weight{j}(:, i) + ...
                lr * dn.z.response{j}';
            dn.y.top_down_synapse_diff{j}(:, i)=(1-lr) * dn.y.top_down_synapse_diff{j}(:, i) + ...
                lr * abs(dn.y.top_down_weight{j}(:, i) - dn.z.response{j}');
            dn.y.top_down_synapse_factor{j}(:, i) = get_synapse_factor(...
                dn.y.top_down_synapse_diff{j}(:,i));
        
        end
        
        % lateral weight and synapse factor
        dn.y.lateral_weight(:, i) = (1-lr) * dn.y.lateral_weight(:, i) + ...
            lr * dn.y.pre_lateral_response';
        dn.y.lateral_synapse_diff(:, i) = (1-lr) * dn.y.lateral_synapse_diff(:, i) + ...
            lr * abs(dn.y.lateral_weight(:, i) - dn.y.pre_lateral_response');
        dn.y.lateral_synapse_factor = get_synapse_factor(...
            dn.y.lateral_synapse_diff(:,i));        
        
        dn.y.firing_age(i) = dn.y.firing_age(i) + 1;
    else if dn.y.lsn_flag(i) == 0  % initialization stage neuron is always updating
            
        else  % update the inhibitive field and weight if a neuron is not firing
            
        end
    end
end

%% Z neuron learning
for area_idx = 1: dn.z.area_num
    for i = 1: dn.z.neuron_num(area_idx)
        if dn.z.response{area_idx}(i) == 1
            
        end
    end
end