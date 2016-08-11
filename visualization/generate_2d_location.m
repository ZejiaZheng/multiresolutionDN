function [neuron_x, neuron_y] = generate_2d_location(dn)
%GENERATE_2D_LOCATION looks at the dn hidden neurons and arrange them
% in clusters according to the PCA results of their bottom up weights,
% and then use top-down class information to pull them together.

%% PCA to get initialized position
% we keep z in case we need to do 3D plots.
weights = zeros(dn.y.neuron_num, dn.x.neuron_num);
for i = 1:dn.y.neuron_num
    weights(i,:) = dn.y.bottom_up_weight(:,i)';    
end
[COEFF, score] = princomp(weights);
neuron_x = score(:,1);
neuron_y = score(:,2);
neuron_z = score(:,3);

neuron_x = 100* (neuron_x - min(neuron_x)) / (max(neuron_x) - min(neuron_x));
neuron_y = 100* (neuron_y - min(neuron_y)) / (max(neuron_y) - min(neuron_y));
neuron_z = 100* (neuron_z - min(neuron_z)) / (max(neuron_z) - min(neuron_z));

% debug plotting
%scatter3(neuron_x, neuron_y, neuron_z, 'b.');

%% generate Z neuron positions, Z neuron positions are hard coded, then we
% move the centern of all hidden neurons of that class to the corresponding
% location.
% first generate Z neuron positions according to where and what
% the Z neurons at a 2D position, [what, where]
% location of Z neurons are named as centers.
interval = floor(100/(dn.z.neuron_num(1)+1));
center_what = interval:interval:(100-interval);
interval = floor(100/(sqrt(dn.z.neuron_num(2))+1));
center_where_col = interval:interval:(100-interval);
center_where_row = interval:interval:(100-interval);
interval = floor(100/prod(dn.z.neuron_num));
center_where = interval:interval:(100-interval);

% Current program only plots these connections in 2d planes, so let's first
% only use center_what. connection_id marks which category the neuron
% belongs to. 
connection_id = zeros(dn.y.neuron_num,1);
pos = zeros(dn.z.neuron_num(1), 2);
count = zeros(dn.z.neuron_num(1), 1);
for i = 1:dn.y.neuron_num
    [~, whatID] = max(dn.y.top_down_weight{1}(:,i));
    [~, whereID] = max(dn.y.top_down_weight{2}(:,i));
    zID = whatID; % change according to requirement.
    connection_id(i) = zID;
    count(zID) = count(zID)+1;
    lr = 1/count(zID);
    pos(zID,1) = lr * neuron_x(i) + (1-lr) * pos(zID,1);
    pos(zID,2) = lr * neuron_y(i) + (1-lr) * pos(zID,2);
end
dest_pos = [center_what; 50*ones(size(center_what))]';

for i = 1:dn.y.neuron_num
    zID = connection_id(i);
    shrink = 0.6;
    neuron_x(i) = neuron_x(i) - (pos(zID, 1) - dest_pos(zID,1));
    neuron_y(i) = neuron_y(i) - (pos(zID, 2) - dest_pos(zID,2));
    neuron_x(i) = shrink * (neuron_x(i) - dest_pos(zID, 1)) + dest_pos(zID, 1);
    neuron_y(i) = shrink * (neuron_y(i) - dest_pos(zID, 2)) + dest_pos(zID, 2);
end

%% now make things evenly distributed by calculating forces
force = zeros(dn.y.neuron_num, 2);
eta = 0.1;
beta = 1;
step = 0.01;
num_loop = 150;
for loop = 1:num_loop
    for i = 1:dn.y.neuron_num
        for j = 1:dn.y.neuron_num
            direction = [neuron_x(i) - neuron_x(j), neuron_y(i) - neuron_y(j)];
            if (direction * direction' ~= 0)
                direction = direction./sqrt(direction * direction');
                amp = 1/(direction * direction');
            else
                amp = 0;
            end
            force(i,1) = eta*amp*direction(1) + force(i,1);
            force(i,2) = eta*amp*direction(2) + force(i,2);
        end
    end
    for i = 1:dn.y.neuron_num
        neuron_x(i) = neuron_x(i) + step*force(i,1);
        neuron_y(i) = neuron_y(i) + step*force(i,2);
    end
end

% range normalization
neuron_x = 100* (neuron_x - min(neuron_x)) / (max(neuron_x) - min(neuron_x));
neuron_y = 100* (neuron_y - min(neuron_y)) / (max(neuron_y) - min(neuron_y));

figure;
hold on;
plot(neuron_x(connection_id==1), neuron_y(connection_id==1), 'b*');
plot(neuron_x(connection_id==2), neuron_y(connection_id==2), 'r*');
end

