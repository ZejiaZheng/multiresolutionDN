path(path, 'data');
path(path, 'functions');
path(path, 'data/backgrounds');
path(path, 'data/foregrounds');


% z_neuron_num = [5, 25] TM, LM; z_neuron_num = [25] LM only
z_neuron_num = [25];
y_neuron_num = 50;
y_top_k = 1;

% foreground is currently set to be 11 by 11
input_dim = [19, 19];

% if this percent of neuron's firing age > threshold, split each neuron
% into split_num neurons
split_percent = 95;
split_threshold = 40;
split_num = 2;
split_firing_age = 5; % after splitting, child neurons would have this firing age

dn = dn_create (input_dim, y_neuron_num, y_top_k, z_neuron_num);

% maybe need to initialize some epsilons to guard synapse maintenance

% TODO: each connection should have its own age

% create training flag and testing flag
training_flag = 1;
testing_flag  = 1;

training_num = 4000; % traing 4000 images 
if(training_flag)
    for i = 1: training_num
        i
        % if numel(z_neuron_num) == 1, then type is always 1
        % if numel(z_neuron_num) == 2, then DN would have type and location
        % motors both
        % get_image need to use figure out the stride of location based on
        % input_dim
        % true_z is the vector containing the maximum index of neurons in
        % each area, e.g true_z = [1,2] means that type 1 is at location 2
        % true_z = [3] means that the foreground is at location 3
        [training_image, true_z] = get_image(input_dim, z_neuron_num);
        
        dn = dn_learn(dn, training_image, true_z);
        %dn = dn_learn(dn, training_image, true_z);
        
        if (check_splitting(dn.y.firing_age, split_threshold, split_percent))
            dn = dn_split(dn, split_num, split_firing_age);
        end
    end
end

if(testing_flag)
    testing_num = 1000;
    error = zeros(size(true_z));
    
    for i = 1: testing_num
        i
        [testing_image, true_z] = get_image(input_dim, z_neuron_num);

        % z_output is the vector with all maximum index of areas in Z
        z_output = dn_test(dn, testing_image);
        
        error = error + (z_output ~= true_z);
    end
end

% report error rate
1 - error/testing_num