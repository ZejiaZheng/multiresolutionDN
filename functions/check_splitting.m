function split_flag = check_splitting(firing_age, threshold, percent)
% if this percent of neuron's firing age > threshold, split
split_flag = 0;
if( mean(firing_age > threshold) > percent)
    split_flag = 1;
end
