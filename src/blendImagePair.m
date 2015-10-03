function out_img = blendImagePair(wrapped_imgs, masks, wrapped_imgd, maskd, mode)
%
% Function used for the blending and overlaying of two given images based
% on the masks given for the images.
%

%Convert images to the double precision to cater to the high resolution
%images
wrapped_imgs = im2double(wrapped_imgs);
wrapped_imgd = im2double(wrapped_imgd);

if(strcmpi(mode,'blend'))
   
   %Finding the distance transform for the mask of both the masks 
   D1 = double(bwdist(~masks));
   D2 = double(bwdist(~maskd));
      
   %Normalizing factor 
   D = D1 + D2 + 0.00001; %To avoid NaN
   
   D1 = D1./D;
   D2 = D2./D;
    
   out_img(:,:,1) = wrapped_imgs(:,:,1).*D1 + wrapped_imgd(:,:,1).*D2; 
   out_img(:,:,2) = wrapped_imgs(:,:,2).*D1 + wrapped_imgd(:,:,2).*D2;  
   out_img(:,:,3) = wrapped_imgs(:,:,3).*D1 + wrapped_imgd(:,:,3).*D2; 
   
   %Type cast back to the readable format
   out_img = double(out_img);
   
elseif(strcmpi(mode,'overlay'))
    %Create mask for image1 for selecting only the part that is to be included in the
    %final image
    wrapped_imgsMask = and(masks, xor(masks,maskd)); 
    
    %Create 3D mask for matrix multiplication
    wrapped_imgsMask = double(wrapped_imgsMask);
    tdMasks(:,:,1)= wrapped_imgsMask;
    tdMasks(:,:,2)= wrapped_imgsMask;
    tdMasks(:,:,3)= wrapped_imgsMask;
      
    %masking for the first image and adding the second image in the masked first image
    out_img = wrapped_imgs.* tdMasks + wrapped_imgd;
end

end