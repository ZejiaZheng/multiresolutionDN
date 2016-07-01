function dn = dn_create(input_dim, y_neuron_num, y_top_k, z_neuron_num)

% we will use image(:) to reshape the x input into a vec
dn.x.neuron_num = 1;
for i = 1:numel(input_dim)
    dn.x.neuron_num = dn.x.neuron_num * (input_dim(i));
end

dn.y.neuron_num = y_neuron_num;

dn.z.area_num = numel(z_neuron_num);
dn.z.neuron_num = z_neuron_num;

% we use sparse to get the all zero matrix

%% ==== ages and learning flags ====
% learning stage flag (only used when initialization at the first generation)
dn.y.lsn_flag = zeros(1,y_neuron_num);

dn.y.firing_age = zeros(1, y_neuron_num);
dn.y.inhibit_age = zeros(1, y_neuron_num);
dn.y.top_k = y_top_k;

%% ==== weights ====
dn.y.bottom_up_weight = ones(dn.x.neuron_num, dn.y.neuron_num);
for i = 1:dn.z.area_num
    dn.y.top_down_weight{i} = zeros(dn.z.neuron_num(i), dn.y.neuron_num);
end
dn.y.lateral_weight = zeros(dn.y.neuron_num, dn.y.neuron_num);

% global inhibit at the beginning
dn.y.inhibit_weight = ones(dn.y.neuron_num, dn.y.neuron_num);

%% ==== synapse factors ====
dn.y.synapse_flag = 0; % 1: only bottom-up
                       % 2: bottom-up + top-down
                       % 3: bottom-up + top-down + lateral
                       % 4: bottom-up + top-down + lateral + inhibit
dn.y.synapse_coefficient = [0.8, 1.2];
dn.y.synapse_age = 15;

dn.y.bottom_up_synapse_diff = zeros(size(dn.y.bottom_up_weight));
dn.y.bottom_up_synapse_factor = ones(size(dn.y.bottom_up_weight));

for i = 1:dn.z.area_num
    dn.y.top_down_synapse_diff{i} = zeros(size(dn.y.top_down_weight{i}));
    dn.y.top_down_synapse_factor{i} = ones(size(dn.y.top_down_weight{i}));
end

dn.y.lateral_synapse_diff = zeros(size(dn.y.lateral_weight));
dn.y.lateral_synapse_factor = ones(size(dn.y.lateral_weight));

dn.y.inhibit_synapse_diff = zeros(size(dn.y.inhibit_weight));
dn.y.inhibit_synapse_factor = ones(size(dn.y.inhibit_weight));

%% ==== z weights ==========
for i = 1:dn.z.area_num
    dn.z.bottom_up_weight{i} = zeros(y_neuron_num, z_neuron_num(i));
    dn.z.firing_age{i} = zeros(z_neuron_num(i));
end

%% ==== responses ==========
dn.x.response = zeros(1, dn.x.neuron_num);
% pre lateral response is bottom up + top down, used to get lateral
% pre response is bottom up + top down + lateral
dn.y.bottom_up_percent = 1/2;
dn.y.top_down_percent  = 1/2;
dn.y.lateral_percent   = 1/2;

dn.y.bottom_up_response = zeros(1, dn.y.neuron_num);
dn.y.top_down_response = zeros(dn.z.area_num, dn.y.neuron_num);
dn.y.pre_lateral_response = zeros(1, dn.y.neuron_num);
dn.y.lateral_response = zeros(1, dn.y.neuron_num);
dn.y.pre_response = zeros(1, dn.y.neuron_num);

% response is after top k
dn.y.response = zeros(1, dn.y.neuron_num);

for i = 1:dn.z.area_num
    dn.z.response{i} = zeros(1, dn.z.neuron_num(i));
end