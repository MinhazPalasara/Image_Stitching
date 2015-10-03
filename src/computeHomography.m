function H_3x3 = computeHomography(src_pts_nx2, dest_pts_nx2)
%
% Function theat computes the homography based on the source and
% destination point coordinates
%
%

j = 1;
A = zeros(size(src_pts_nx2,1)*2,9);

for i= 1:size(src_pts_nx2)

A(j,:) = [src_pts_nx2(i,1) src_pts_nx2(i,2) 1 0 0 0 -src_pts_nx2(i,1)*dest_pts_nx2(i,1)  -src_pts_nx2(i,2)*dest_pts_nx2(i,1) -dest_pts_nx2(i,1)];
j = j + 1;
A(j,:) = [0 0 0 src_pts_nx2(i,1) src_pts_nx2(i,2) 1 -src_pts_nx2(i,1)*dest_pts_nx2(i,2)  -src_pts_nx2(i,2)*dest_pts_nx2(i,2) -dest_pts_nx2(i,2)]; 
j = j + 1;

end

%Get the eigen value of the matrix
[V,D] = eig(A'*A);

%Convert the resultant vector into 3x3 matri,
H_3x3 = vec2mat(V(:,1),3);

end