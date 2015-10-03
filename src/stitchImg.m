function stitched_img = stitchImg(varargin)
%
% Function stitches the variable number of images 
%
%

if(size(varargin,2)>1)    

  ref = ceil(size(varargin,2)/2);
  refImg = varargin{1,ref};
  leftImageIndex = ceil(size(varargin,2)/2) - 1;
  rightImageIndex = ceil(size(varargin,2)/2) + 1;
  
  while(leftImageIndex >= 1  || rightImageIndex <= size(varargin,2) )
          if(leftImageIndex < 1 && rightImageIndex <= size(varargin,2)) % do only right stitching
              
              [rpad,rtopPad,rbottomPad,rmasks,rmaskd,rsrc_warp, rdest] = rightStitch(varargin{1,rightImageIndex},refImg);
              refImg = blendImagePair(rdest,rmaskd, rsrc_warp, rmasks, 'blend');            
              rightImageIndex = rightImageIndex + 1;

          elseif(rightImageIndex > size(varargin,2) && leftImageIndex > 1) % do only left stitching

              [lpad,ltopPad,lbottomPad,lmasks,lmaskd,lsrc_warp, ldest] = leftStitch(varargin{1,leftImageIndex},refImg);
              refImg = blendImagePair(lsrc_warp, lmasks, ldest, lmaskd, 'blend');      
              leftImageIndex = leftImageIndex - 1;

          else      
                      [lpad,ltopPad,lbottomPad,lmasks,lmaskd,lsrc_warp, ldest] = leftStitch(varargin{1,leftImageIndex},refImg);   
                      [rpad,rtopPad,rbottomPad,rmasks,rmaskd,rsrc_warp, rdest] = rightStitch(varargin{1,rightImageIndex},refImg);

                      %After having the warped images with both left and right stitch find blend all the three warps.
                      % First equalize the warping masks and the images

                      %1. Add left pad to the right warped source image
                        rmasks = [zeros(size(rmasks,1),lpad) rmasks];
                        rsrc_warp = [zeros(size(rsrc_warp,1),lpad,3) rsrc_warp];

                        lmasks = [lmasks zeros(size(lmasks,1),rpad)];
                        lsrc_warp = [lsrc_warp zeros(size(lsrc_warp,1),rpad,3)];

                        lmaskd = [lmaskd zeros(size(lmaskd,1),rpad)];
                        ldest = [ldest zeros(size(ldest,1),rpad,3)];

                      %2. Pad lower height and upper height to the image which was padded less
                      %than the other
                      if(ltopPad > rtopPad)%pad the right one
                           rmasks = [zeros(abs(rtopPad - ltopPad),size(rmasks,2)); rmasks];
                           rsrc_warp = [zeros(abs(rtopPad - ltopPad),size(rsrc_warp,2),3); rsrc_warp];
                      else %pad center and the left
                          lmasks = [zeros(abs(rtopPad - ltopPad),size(lmasks,2)); lmasks];
                          lsrc_warp = [zeros(abs(rtopPad - ltopPad),size(lsrc_warp,2),3); lsrc_warp];

                          lmaskd = [zeros(abs(rtopPad - ltopPad),size(lmaskd,2)); lmaskd];
                          ldest = [zeros(abs(rtopPad - ltopPad),size(ldest,2),3); ldest];      
                      end

                      %3. Pad upper height and upper height to the image which was padded less
                      %than the other
                      if(lbottomPad > rbottomPad)%pad the right one
                           rmasks =  [rmasks ; zeros(abs(rbottomPad - lbottomPad),size(rmasks,2))];
                           rsrc_warp = [rsrc_warp ; zeros(abs(rbottomPad - lbottomPad),size(rsrc_warp,2),3)];
                      else %pad center and the left
                          lmasks = [lmasks ; zeros(abs(rbottomPad - lbottomPad),size(lmasks,2))];
                          lsrc_warp = [ lsrc_warp ; zeros(abs(rbottomPad - lbottomPad),size(lsrc_warp,2),3)];

                          lmaskd = [ lmaskd ; zeros(abs(rbottomPad - lbottomPad),size(lmaskd,2))];
                          ldest = [ ldest; zeros(abs(rbottomPad - lbottomPad),size(ldest,2),3)];      
                      end

                      out_image = blendImagePair(lsrc_warp, lmasks, ldest, lmaskd, 'blend');
                      stitched_img = blendImagePair(out_image, or(lmasks,lmaskd), rsrc_warp, rmasks, 'blend');
                      refImg = stitched_img;  

                      leftImageIndex = leftImageIndex - 1;
                      rightImageIndex = rightImageIndex + 1;              
          end
    
  end
   
end
  
stitched_img = refImg; 

end


%% Function used for the left side stitch. In this approach the source image is on the left side of reference image
function [lowerBoundWidth,lowerPad,upperPad,masks,maskd,source_warp,destination] = leftStitch(source,destination)

   %Height Lower padding and upper padding
   lowerPad = 0;
   upperPad = 0;
    
   [xs, xd] = genSIFTMatches(source, destination);
   [~,H_3x3] = runRANSAC(xs, xd, 50, 3);

   %finding the bound in an image
   %   P1-------P3
   %   |         |
   %   |         |
   %   P2--------P4
   %Calculate How much of padding required each side
   result1 = H_3x3*[0;0;1];
   result1 = bsxfun (@rdivide, result1, result1(3,:));
   
   result2 = H_3x3*[0;size(source,1);1];
   result2 = bsxfun (@rdivide, result2, result2(3,:));
   
   result3 = H_3x3*[size(source,2);0;1];
   result3 = bsxfun (@rdivide, result3, result3(3,:));
    
   result4 = H_3x3*[size(source,2);size(source,1);1];
   result4 = bsxfun (@rdivide, result4, result4(3,:));
   
   lowerBoundWidth = int16(abs(floor(min(result1(1,1),result2(1,1)))));
  
   lowerBoundHeight = min(result3(2,1),result1(2,1));
   upperBoundHeight = max(result2(2,1),result4(2,1));
   
   if(lowerBoundHeight<0)
     lowerPad = int16(abs(floor(lowerBoundHeight)));
   end    
   
   if(upperBoundHeight> size(destination,1))
      upperPad = int16(abs(ceil(size(destination,1) - upperBoundHeight))); 
   end
   
   
   %BackWarping by adding translation matrix
   transH = double([ 1 0 lowerBoundWidth;0 1 lowerPad;0 0 1]);
   
   dest_canvas_width_height = [lowerBoundWidth+size(destination,2) lowerPad+upperPad+size(destination,1)];
   [masks, source_warp]  = backwardWarpImg(source, inv(transH * H_3x3),dest_canvas_width_height);
      
   % creating the destination mask by padding 
   maskd = [zeros(size(destination,1),lowerBoundWidth) ones(size(destination,1),size(destination,2))];
   maskd = [zeros(lowerPad,size(maskd,2)); maskd; zeros(upperPad,size(maskd,2))];
   
   padding = zeros(size(destination,1),int64(abs(lowerBoundWidth)),3);
   destination = [padding destination];%shifting the destination image
   destination = [zeros(lowerPad,size(destination,2),3);destination;zeros(upperPad,size(destination,2),3)];
end

%% %% Function used for the left side stitch. In this approach the source image is on the left side of reference image
%Same as the left stitch only difference is in the padding side and the
%transalation homography
function [lowerBoundWidth,lowerPad,upperPad,masks,maskd,source_warp,destination] = rightStitch(source, destination)

   lowerPad = 0;
   upperPad = 0;
    
   [xs, xd] = genSIFTMatches(source, destination);
   [~,H_3x3] = runRANSAC(xs, xd, 50, 3);

   %finding the bound in an image
   %   P1-------P3
   %   |         |
   %   |         |
   %   P2--------P4
   result1 = H_3x3*[0;0;1];
   result1 = bsxfun (@rdivide, result1, result1(3,:));
   
   result2 = H_3x3*[0;size(source,1);1];
   result2 = bsxfun (@rdivide, result2, result2(3,:));
   
   result3 = H_3x3*[size(source,2);0;1];
   result3 = bsxfun (@rdivide, result3, result3(3,:));
    
   result4 = H_3x3*[size(source,2);size(source,1);1];
   result4 = bsxfun (@rdivide, result4, result4(3,:));
   
   lowerBoundWidth = int16(abs(floor(max(result3(1,1),result4(1,1))) - size(destination,2) ) );
  
   lowerBoundHeight = min(result3(2,1),result1(2,1));
   upperBoundHeight = max(result2(2,1),result4(2,1));
 
   if(lowerBoundHeight < 0)
     lowerPad = int16(abs(floor(lowerBoundHeight)));
   end    
   
   if(upperBoundHeight> size(destination,1))
      upperPad = int16(abs(ceil(size(destination,1) - upperBoundHeight))); 
   end
   
   transH = double([ 1 0 0;0 1 lowerPad;0 0 1]);
   
   dest_canvas_width_height = [lowerBoundWidth+size(destination,2) lowerPad+upperPad+size(destination,1)];
   [masks, source_warp]  = backwardWarpImg(source, inv(transH * H_3x3),dest_canvas_width_height);
      
   % creating the destination mask by padding 
   maskd = [ones(size(destination,1),size(destination,2)) zeros(size(destination,1),lowerBoundWidth)];
   maskd = [zeros(lowerPad,size(maskd,2)); maskd; zeros(upperPad,size(maskd,2))];
   
   padding = zeros(size(destination,1),int64(abs(lowerBoundWidth)),3);
   destination = [destination padding];%shifting the destination image
   destination = [zeros(lowerPad,size(destination,2),3);destination;zeros(upperPad,size(destination,2),3)];

   
end