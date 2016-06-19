clear
clc
b=[];
for i=1:13
    i
    filename = sprintf('%01d.tiff',i);
    a=imread(filename);
    a=double(a(:));
    b=[b;a];
    [mu,sigma] = normfit(a)
end
 [mu,sigma] = normfit(b)