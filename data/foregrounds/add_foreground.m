function [image,type,position]=add_foreground(background,training_type)
% 01:cat; 02:dog; 03:elephant; 04:pig; 05:truck
listdata = 'foregrounds_to_use.txt';
filedata = textread(listdata,'%s','delimiter','\n','whitespace','');
format = char(filedata(1));
curr_num = ceil(rand() * training_type)+1;
type = curr_num-1;
[img,~,alpha] = imread(strcat('', char(filedata(curr_num)), '.', format),format);
img = double(img);
alpha = double(alpha > 0);

objWidth=size(img,1);

p_r=ceil(rand*5);
p_c=ceil(rand*5);
position=(p_r-1)*5+p_c;
r=1+(p_r-1)*2;
c=1+(p_c-1)*2;
alpmin=min(min(alpha));
alpmax=max(max(alpha));
alpha=(alpha-alpmin)./(alpmax-alpmin);
img = img.*alpha;                                               %paste
imgmin=min(min(img));
imgmax=max(max(img));
img=(img-imgmin)./(imgmax-imgmin);

% background(r:r+objWidth-1, c:c+objWidth-1)=img;   %TODO: bounds checking
temp = background(r:r+objWidth-1, c:c+objWidth-1);
temp = (1-alpha).*temp+alpha.*img;                                %paste
% temp = img;

background(r:r+objWidth-1, c:c+objWidth-1)=temp;
% vectorize the geneerated sample
image=background;
end