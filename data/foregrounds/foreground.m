function image=foreground
 path(path, 'foregrounds');
  listdata = 'foregrounds_to_use.txt';
  filedata = textread(listdata,'%s','delimiter','\n','whitespace','');
  format = char(filedata(1));
  nImg = size(filedata, 1) - 1;
  curr_num = max(2,ceil(rand*nImg));
   [img,map,alpha] = imread(strcat('', char(filedata(curr_num)), '.', format),format);
    img = double(img);
    alpha = double(alpha);

   objWidth=size(img,1)
   objHeight=size(img,2)
end