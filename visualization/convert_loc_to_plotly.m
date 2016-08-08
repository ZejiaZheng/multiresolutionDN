function [] = convert_loc_to_plotly(neuron_x, neuron_y, dn, split_count)
% positions of hidden neurons
Xn = neuron_x';
Yn = neuron_y';
Zn = ones(size(neuron_x'));

% group labels of hidden neurons
group_what = zeros(size(Xn));
free_what_group = dn.z.neuron_num(1)+1;
group_where = zeros(size(Xn));
free_where_group = dn.z.neuron_num(2)+1;
for i = 1:dn.y.neuron_num
    if (dn.y.firing_age(i)>5)
    [~, whatID] = max(dn.y.top_down_weight{1}(:,i));
    [~, whereID] = max(dn.y.top_down_weight{2}(:,i));
    
    group_what(i) = whatID;
    group_where(i) = whereID;
    else
        group_what(i) = free_what_group;
        group_where(i) = free_where_group;
    end
end

% plot edges
Xe = [];
Ye = [];
Ze = [];
for i = 1:dn.y.neuron_num
    for j = 1:dn.y.neuron_num
        if (dn.y.firing_age(i)>5 && dn.y.firing_age(j)>5)
            if (dn.y.inhibit_weight(j,i)>0.6)
                Xe = [Xe, Xn(i), Xn(j)];
                Ye = [Ye, Yn(i), Yn(j)];
                Ze = [Ze, 1,     1];
            end
        end
    end
end
file_name = sprintf('./result/pyplot_data_split_%d', split_count);
save(file_name, 'Xn', 'Yn', 'Zn', 'Xe', 'Ye', 'Ze', 'group_what', 'group_where');