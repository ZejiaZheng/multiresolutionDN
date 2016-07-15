function new_dn = dn_split(dn, split_num, split_firing_age)

input_dim = dn.x.neuron_num;
y_top_k = dn.y.top_k;
z_neuron_num = dn.z.neuron_num;
y_neuron_num = dn.y.neuron_num * split_num;

new_to_old_index = zeros(1, y_neuron_num);
for i = 1:dn.y.neuron_num
    start_ind = (i-1) * split_num + 1;
    end_ind = i * split_num;
    new_to_old_index(start_ind:end_ind) = i;
end

% we first create a brand new dn with the neurons
synapse_flag = dn.y.synapse_flag;
inhibit_synapse_thresh = dn.y.inhibit_synapse_thresh; % see top_k competition to find out about usage
synapse_age = dn.y.synapse_age;synapse_lower_percent = dn.y.synapse_coefficient(1);
synapse_upper_percent = dn.y.synapse_coefficient(2);
synapse_param = [synapse_flag, inhibit_synapse_thresh, synapse_age, ...
    synapse_lower_percent, synapse_upper_percent];
new_dn = dn_create(input_dim, y_neuron_num, y_top_k, z_neuron_num, synapse_param);

% now we duplicate the weights
for i = 1: new_dn.y.neuron_num
    j = new_to_old_index(i);
    %TODO(zejia): Do we inherit initialization flag?
    new_dn.y.lsn_flag(i) = dn.y.lsn_flag(j);
    %new_dn.y.lsn_flag(i) = 0;
    new_dn.y.firing_age(i) = split_firing_age;
    new_dn.y.inhibit_age(i) = split_firing_age;
    
    % introduce some small change to the weight inherited so that the
    % resposne would be slightly different across neurons
    new_dn.y.bottom_up_weight(:, i) = dn.y.bottom_up_weight(:, j) + ...
        generate_rand_mutate(size(dn.y.bottom_up_weight(:, j)));
    new_dn.y.bottom_up_weight(:, i) = dn.y.bottom_up_weight(:, j)/...
        max(new_dn.y.bottom_up_weight(:, j));
    for z_ind = 1:new_dn.z.area_num
        new_dn.y.top_down_weight{z_ind}(:, i) = dn.y.top_down_weight{z_ind}(:, j) + ...
            generate_rand_mutate(size(dn.y.top_down_weight{z_ind}(:, j)));
        new_dn.y.top_down_weight{z_ind}(:, i) = new_dn.y.top_down_weight{z_ind}(:, i)/...
            max(new_dn.y.top_down_weight{z_ind}(:, i));
    end
    
    % TODO: lateral_weight is more complicated
    % need to check correctness !!
    new_dn.y.lateral_weight(:, i) = dn.y.lateral_weight(new_to_old_index, j);
    
    new_dn.y.inhibit_weight(:, i) = dn.y.inhibit_weight(new_to_old_index,j) + ...
        generate_rand_mutate(size(dn.y.inhibit_weight(new_to_old_index,j)));
    
    new_dn.y.inhibit_weight(:, i) = new_dn.y.inhibit_weight(:, i) ./ ...
        max(new_dn.y.inhibit_weight(:, i));
    
    % synapse factors currently do not subject to random changes
    new_dn.y.bottom_up_synapse_diff(:, i) = dn.y.bottom_up_synapse_diff(:, j);
    new_dn.y.bottom_up_synapse_factor(:,i) = ones(size(dn.y.bottom_up_synapse_factor(:, j)));
    
    for z_ind = 1:new_dn.z.area_num
        new_dn.y.top_down_synapse_diff{z_ind}(:, i) = dn.y.top_down_synapse_diff{z_ind}(:,j);
        new_dn.y.top_down_synapse_factor{z_ind}(:, i) = ones(size(dn.y.top_down_synapse_factor{z_ind}(:,j)));
    end
    
    
    % TODO: check the correctness of this!!
    new_dn.y.lateral_synapse_diff(:,i) = dn.y.lateral_synapse_diff(new_to_old_index, j);
    new_dn.y.lateral_synapse_factor(:,i) = ones(size(dn.y.lateral_synapse_factor(new_to_old_index,j)));
    
    new_dn.y.inhibit_synapse_diff(:,i) = dn.y.inhibit_synapse_diff(new_to_old_index, j);
    new_dn.y.inhibit_synapse_factor(:,i) = ones(size(dn.y.inhibit_synapse_factor(new_to_old_index, j)));
    
    % Z weights
    for z_ind = 1:new_dn.z.area_num
        new_dn.z.bottom_up_weight{z_ind}(i, :) = dn.z.bottom_up_weight{z_ind}(j,:);
    end
end

for z_ind = 1:new_dn.z.area_num
    new_dn.z.firing_age{z_ind} = ones(size(dn.z.firing_age{z_ind})) * 1;
end
