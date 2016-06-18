function dn = dn_create(input_dim, y_neuron_num, z_neuron_num)

% we will use image(:) to reshape the x input into a vec
dn.x.neuron_num = 1;
for i = 1:numel(input_dim)
    dn.x.neuron_num = dn.x.neuron_num * (input_dim(i));
end

dn.y.neuron_num = y_neuron_num;

dn.z.area_num = numel(z_neuron_num);
dn.z.neuron_num = z_neuron_num;

% we use sparse to get the all zero matrix

% ==== ages and learning flags ====
% learning stage flag (only used when initialization at the first generation)
dn.y.lsn_flag = zeros(1,y_neuron_num);
% firing age
dn.y.firing_age = zeros(1, y_neuron_num);
% inhibitive firing age
dn.y.inhibit_age = zeros(1, y_neuron_num);

% ==== weights ====
% bottom_up_weight
dn.y.bottom_up_weight = zeros(dn.x.neuron_num, dn.y.neuron_num);
% top_down_weight
for i = 1:dn.z.area_num
    dn.y.top_down_weight{i} = zeros(dn.z.neuron_num(i), dn.y.neuron_num);
end
% lateral_weight
dn.y.lateral_weight = zeros(dn.y.neuron_num, dn.y.neuron_num);

% ==== synapse factors ====
dn.y.bottom_up_synapse_diff = zeros(size(dn.y.bottom_up_weight));
dn.y.bottom_up_synapse_factor = ones(size(dn.y.bottom_up_weight));

dn.y.top_down_synapse_diff = zeros(size(dn.y.top_down_weight));
dn.y.top_down_synapse_factor = ones(size(dn.y.top_down_weight));

dn.y.lateral_synapse_diff = zeros(size(dn.y.lateral_weight));
dn.y.lateral_syanpse_factor = ones(size(dn.y.lateral_weight));