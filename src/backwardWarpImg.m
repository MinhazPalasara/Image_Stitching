function [mask, result_img] = backwardWarpImg(src_img, resultToSrc_H,...
                              dest_canvas_width_height)
 %                         
 % Function is used for the backward warping of the image. Nearest
 % Neighbour method is used for the warping
 %

 result_img = zeros(dest_canvas_width_height(1,2),dest_canvas_width_height(1,1),3);
 mask = zeros(dest_canvas_width_height(1,2),dest_canvas_width_height(1,1));
 
 %% This code can easily be converted into vector..indexes are rounded of to get the nearest neighbour
 %% This pixel value is set in the warped image
 for i=1:size(result_img,2)
    for j=1:size(result_img,1)                      
                       
    result = resultToSrc_H * [i; j; 1];                      
    result(1,1) = result(1,1)/result(3,1);                      
    result(2,1) = result(2,1)/result(3,1);                      

    if(result(1,1)>=1 && result(1,1)<= size(src_img,2) && result(2,1)>=1 && result(2,1)<= size(src_img,1))
       result(1,1) = round(result(1,1));
       result(2,1) = round(result(2,1));
       result_img(j,i,1) = src_img(result(2,1),result(1,1),1);  
       result_img(j,i,2) = src_img(result(2,1),result(1,1),2); 
       result_img(j,i,3) = src_img(result(2,1),result(1,1),3);
       mask(j,i) = 1;
    end
  
    end
 end               
                          
end
