function input = preprocess(input)
input = input - mean(input);
max_val = max(input);
min_val = min(input);

if (max_val - min_val) ~= 0
    input = (input - min_val)/(max_val - min_val);
end