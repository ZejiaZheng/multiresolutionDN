function [training_image, true_z] = get_image(input_dim, z_neuron_num) 
% 1:cat; 2:dog; 3:elephant; 4:pig; 5:truck
%position:(row-1)*col

epsilon_error = 1/(256*sqrt(12));
background_width=input_dim(1);
background_height=input_dim(2);
training_type=1;
 
bg=get_background(background_height,background_width);
 

if(numel(z_neuron_num) == 1)
    training_type=0;
end
[training_image,type,position]=add_foreground(bg,training_type);
 
if(type>0)
    true_z=zeros(1,2);
    true_z(1)=type;
    true_z(2)=position;
else
    true_z=position;
end
%   figure;
%   imagesc(training_image);
end