function dest_pts_nx2 = applyHomography(H_3x3, src_pts_nx2)
%
% Function applies the Homography oh the source image points and returns
% the destination points that are obtained in the operation
%
%

dest_pts_nx2 = zeros(size(src_pts_nx2,1),2);

% for i = 1: size(src_pts_nx2,1)
% 
% vector  = [src_pts_nx2(i,1) src_pts_nx2(i,2) 1];
% result =  H_3x3 * vector';
% dest_pts_nx2(i,:) = [result(1,1)/result(3,1) result(2,1)/result(3,1)];
%     
% end

vector = src_pts_nx2';
vector(3,:) = ones(1,size(vector,2));
vector = H_3x3 * vector;
vector = bsxfun (@rdivide, vector, vector(3,:));
dest_pts_nx2(:,1) = vector(1,:)';
dest_pts_nx2(:,2) = vector(2,:)';


end