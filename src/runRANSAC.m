function [inliers_id, H] = runRANSAC(Xs, Xd, ransac_n, eps)



numInlier = 0;
inliers_id = [];

for i = 1:ransac_n 

%% Randomly arrange indices    
ind = randperm(size(Xs,1));

%% Find Homography based on the first 4 points
H_3x3 = computeHomography(Xs(ind(1:4),:),Xd(ind(1:4),:));

% Arrange the point in the [XXXXXX;YYYYY;ZZZZZZ] pattern based on the
% permuted indices
XsR = Xs(ind(5:end),:)';
XsR(3,:) = ones(1,size(XsR,2)); 

XdR = Xd(ind(5:end),:)';
XdR(3,:) = ones(1,size(XdR,2));

%perform multiplication with Homography matrix to find the destination
%points
newXd = H_3x3 * XsR;

%make z coordinate 1 by dividing all the rows by the third row
newXd = bsxfun (@rdivide, newXd, newXd(3,:));

%Compare actual destination and the found destination points
result = sum((XdR-newXd).^2);

%find the points that are within the epsilon bound
[~,c,~] = find(result <= eps^2);

if(size(c,2)>numInlier)
 numInlier = size(c,2);
 inliers_id = [ind(c + 4)]; 
 H = H_3x3;
end


end;









end