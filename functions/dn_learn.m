function dn = dn_learn(dn, training_image, true_z)

dn.x.response = training_image(:)';
for i = 1:dn.z.area_num
    dn.z.response{i} = zeros(size(dn.z.response{i}));
    dn.z.response{i}(true_z(i)) = 1;
end

% TODO: preprocess data
dn.x.response = preprocess(dn.x.response);

%% compute responses
dn.y.bottom_up_response = compute_response(dn.x.response, ...
    dn.y.bottom_up_weight, ...
    dn.y.bottom_up_synapse_factor);
for i = 1:dn.z.area_num
    dn.y.top_down_response(i,:) = compute_response(dn.z.response{i}, ...
        dn.y.top_down_weight{i}, ...
        dn.y.top_down_synapse_factor{i});
end

dn.y.pre_lateral_response = (dn.y.bottom_up_percent* dn.y.bottom_up_response + ...
    dn.y.top_down_percent* mean(dn.y.top_down_response, 1)) / ...
    (dn.y.bottom_up_percent + dn.y.top_down_percent);

dn.y.lateral_response = compute_response(dn.y.pre_lateral_response, ...
    dn.y.lateral_weight, ...
    dn.y.lateral_synapse_factor);
dn.y.pre_response = (dn.y.bottom_up_percent + dn.y.top_down_percent) * ...
    dn.y.pre_lateral_response + dn.y.lateral_percent * ...
    dn.y.lateral_response;

% top-k competition for each neuron
dn.y.response = top_k_competition(dn.y.pre_response, dn.y.top_down_response, dn.y.inhibit_weight, ...
    dn.y.inhibit_synapse_factor, dn.y.top_k);


%% hebbian learning and synapse maitenance
for i = 1: dn.y.neuron_num    
    if dn.y.response(i) == 1  % firing neuron, currently set response to 1
        dn.y.lsn_flag(i) = 1;
        lr = get_learning_rate(dn.y.firing_age(i)); % learning rate
        
        % TODO: check if we want to use y_bottom_up input instead of x
        % response to to weight update, namely, do we need to 
        
        % bottom-up weight and synapse factor
        normed_input = dn.x.response'.* dn.y.bottom_up_synapse_factor(:,i);
        %normed_input = normed_input/ norm(normed_input);
        dn.y.bottom_up_weight(:, i) = (1-lr) * dn.y.bottom_up_weight(:, i) + ...
            lr * normed_input;
        dn.y.bottom_up_weight(:, i) = dn.y.bottom_up_weight(:, i) .* ...
            dn.y.bottom_up_synapse_factor(:, i);
        %dn.y.bottom_up_weight(:, i) = dn.y.bottom_up_weight(:, i) / norm(dn.y.bottom_up_weight(:, i));
        
        dn.y.bottom_up_synapse_diff(:,i) = (1-lr) * dn.y.bottom_up_synapse_diff(:, i) + ...
            lr * abs(dn.y.bottom_up_weight(:, i) - normed_input);
        
        if (dn.y.synapse_flag>0 && dn.y.firing_age(i) > dn.y.synapse_age)
            dn.y.bottom_up_synapse_factor(:, i) = get_synapse_factor(...
                dn.y.bottom_up_synapse_diff(:,i), dn.y.bottom_up_synapse_factor(:, i), ...
                dn.y.synapse_coefficient);
        end
        
        % top-down weight and synapse factor
        for j = 1:dn.z.area_num
            dn.y.top_down_weight{j}(:, i) = (1-lr) * dn.y.top_down_weight{j}(:, i) + ...
                lr * dn.z.response{j}';
            dn.y.top_down_synapse_diff{j}(:, i)=(1-lr) * dn.y.top_down_synapse_diff{j}(:, i) + ...
                    lr * abs(dn.y.top_down_weight{j}(:, i) - dn.z.response{j}');
            if (dn.y.synapse_flag>1 && dn.y.firing_age(i) > dn.y.synapse_age)                
                dn.y.top_down_synapse_factor{j}(:, i) = get_synapse_factor(...
                    dn.y.top_down_synapse_diff{j}(:,i), dn.y.top_down_synapse_factor{j}(:,i), ...
                    dn.y.synapse_coefficient);
            end
        
        end
        
        % lateral weight and synapse factor
        % lateral exitation connection only exists within firing neurons
        dn.y.lateral_weight(:, i) = (1-lr) * dn.y.lateral_weight(:, i) + ...
            lr * dn.y.response';
        dn.y.lateral_synapse_diff(:, i) = (1-lr) * dn.y.lateral_synapse_diff(:, i) + ...
                lr * abs(dn.y.lateral_weight(:, i) - dn.y.response');
        if (dn.y.synapse_flag>2 && dn.y.firing_age(i) > dn.y.synapse_age)            
            dn.y.lateral_synapse_factor(:, i) = get_synapse_factor(...
                dn.y.lateral_synapse_diff(:,i), dn.y.lateral_synapse_factor(:, i), ...
                dn.y.synapse_coefficient);        
        end
        
        dn.y.firing_age(i) = dn.y.firing_age(i) + 1;
    else if dn.y.lsn_flag(i) == 0  % initialization stage neuron is always updating
            dn.y.bottom_up_weight(:,i) = dn.x.response';
            for j = 1:dn.z.area_num
                dn.y.top_down_weight{j}(:,i) = dn.z.response{j};
            end
            dn.y.lateral_weight(:, i) = dn.y.response';
            
        else  % update the inhibitive field and weight if a neuron is not firing
              % TODO : do we use pre lateral response or final response?
              % what if all the neurons inside the inhibitive area are
              % inhibited, current solution: the neuron is only inhibited
              % by the other neurons within its rf and with a response
              % higher than its response value              
            lr = get_learning_rate(dn.y.inhibit_age(i));
            temp = zeros(size(dn.y.inhibit_synapse_factor));
            for j = 1:dn.y.neuron_num
                temp(:, j) = dn.y.pre_lateral_response' .* dn.y.inhibit_synapse_factor(:,j);
                temp(:, j) = temp(:, j) > dn.y.pre_lateral_response(i);
            end
            
            dn.y.inhibit_weight(:, i) = (1-lr) * dn.y.inhibit_weight(:, i) + ...
                lr * temp(:, i);
            dn.y.inhibit_synapse_diff(:, i) = (1-lr) * dn.y.inhibit_synapse_diff(:, i) + ...
                    lr * abs(dn.y.inhibit_weight(:, i) - temp(:, i));
            if (dn.y.synapse_flag>3 && dn.y.firing_age(i) > dn.y.synapse_age)                
                dn.y.inhibit_synapse_factor(:, i) = get_synapse_factor(...
                    dn.y.inhibit_synapse_diff(:, i), dn.y.inhibit_synapse_factor(:, i), ...
                    dn.y.synapse_coefficient);
            end            
            dn.y.inhibit_age(i) = dn.y.inhibit_age(i) + 1;
        end
    end
end

%% Z neuron learning
for area_idx = 1: dn.z.area_num
    for i = 1: dn.z.neuron_num(area_idx)
        if dn.z.response{area_idx}(i) == 1
            lr = get_learning_rate(dn.z.firing_age{area_idx}(i));
            dn.z.bottom_up_weight{area_idx}(:,i) = (1-lr) * dn.z.bottom_up_weight{area_idx}(:,i)+ ...
                lr * dn.y.response';
            dn.z.firing_age{area_idx}(i) = dn.z.firing_age{area_idx}(i)+1;
        end
    end
end