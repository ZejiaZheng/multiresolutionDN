path(path, 'data');
path(path, 'data/backgrounds');
path(path, 'data/foregrounds');


% if z_area_num = 2; then z_neuron_num = [5, 25] TM, LM
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
    [training_image, true_pos, true_type] = get_image(input_dim, z_neuron_num);
end