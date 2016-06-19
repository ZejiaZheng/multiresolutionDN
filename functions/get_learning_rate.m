function lr = get_learning_rate(firing_age)
lr = 1/(firing_age+1);
if lr < 1/50
    lr = 1/50;
end