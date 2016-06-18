path(path, 'data');
path(path, 'data/backgrounds');
path(path, 'data/foregrounds');


% z_neuron_num = [5, 25] TM, LM; z_neuron_num = [25] LM only
z_neuron_num = [25];
y_neuron_num = 4;
input_dim = [18, 18];
network = dn_create (input_dim, y_neuron_num, z_neuron_num);

% maybe need to initialize some epsilons to guard synapse maintenance

% create training flag and testing flag
training_flag = 1;
testing_flag  = 1;

training_num = 4000; % traing 4000 images 
if(training_flag)
    for i = 1: training_num
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
        
        if (check_splitting(dn))
            dn = dn_split(dn);
        end
    end
end

testing_num = 1000;
if(testing_flag)
    type_error = 0;
    location_error = 0;
    
    [testing_image, true_z] = get_image(input_dim, z_neuron_num);
    
    % z_output is the vector with all maximum index of areas in Z
    z_output = dn_test(dn, testing_image);
end