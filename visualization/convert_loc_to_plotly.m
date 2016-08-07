function [] = convert_loc_to_plotly(neuron_x, neuron_y, dn)
% positions of hidden neurons
Xn = neuron_x';
Yn = neuron_y';
Zn = ones(size(neuron_x'));

% group labels of hidden neurons
group_what = zeros(size(Xn));
free_what = dn.z.neuron_num(1)
group_where = zeros(size(Xn));
for i = 1:dn.y.neuron_num
    [~, whatID] = max(dn.y.top_down_weight{1}(:,i));
    [~, whereID] = max(dn.y.top_down_weight{2}(:,i));
    
    group_what(i) = whatID;
    group_where(i) = whereID;
end

% plot edges
Xe = [];
Ye = [];
Ze = [];
for i = 1:dn.y.neuron_num
    for j = 1:dn.y.neuron_num
        if (dn.y.inhibit_weight(j,i)>0.9)
            Xe = [Xe, Xn(i), Xn(j)];
            Ye = [Ye, Yn(i), Yn(j)];
            Ze = [Ze, 1,     1];
        end
    end
end
save('result/pyplot_data', 'Xn', 'Yn', 'Zn', 'Xe', 'Ye', 'Ze', 'group_what');