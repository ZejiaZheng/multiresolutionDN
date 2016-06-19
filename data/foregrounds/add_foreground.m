function [image,type,position]=add_foreground(background,training_type) 
  type=0; % 01:cat; 02:dog; 03:elephant; 04:pig; 05:truck
  listdata = 'foregrounds_to_use.txt';
  filedata = textread(listdata,'%s','delimiter','\n','whitespace','');
  format = char(filedata(1));
  nImg = size(filedata, 1) - 1;
  curr_num = max(2,ceil(rand*nImg));
   [img,map,alpha] = imread(strcat('', char(filedata(curr_num)), '.', format),format);
    img = double(img);
    alpha = double(alpha);
    
    if(training_type)
        fg = textscan( char(filedata{curr_num}), '%s%s','delimiter', '_');
        class = char(fg{1});
        type=str2num(class);
    end
 
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
% Vectorize the geneerated sample
 image=background;
end