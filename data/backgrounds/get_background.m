function bg=get_background(background_height,background_width)
  epsilon_error = 1/(256*sqrt(12));
  listData = 'backgrounds_to_use.txt';
  fileData = textread(listData,'%s','delimiter','\n','whitespace','');
  format = char(fileData(1));
  nImg = size(fileData, 1) - 1;
  curr_num = max(2,ceil(rand*nImg));
   [curr_image,map,alpha] = imread(strcat('', char(fileData(curr_num)), '.', format),format);
        curr_image = double(curr_image);
        alpha = double(alpha);
    [rows,cols] = size( curr_image );
    ul_row = ceil( rand * (rows - background_height + 1) ); %topmost window row
    ul_col = ceil( rand * (cols - background_width + 1) ); %leftmost window col
    bg = curr_image( ul_row : ul_row +background_height-1, ul_col : ul_col + background_width-1 );
    bg1 = bg(:);
    samplemin=min(bg1);
    samplemax=max(bg1);
    bg=(bg-samplemin)./(samplemax-samplemin+epsilon_error);
    
    %disp('ok');
end