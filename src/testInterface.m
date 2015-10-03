function testInterface(varargin)
% testInterface is the "main" interface that lists a set of 
% functions corresponding to the problems that need to be solved.
%
% Note that this file also serves as the specifications for the functions 
% implemented.

% Settings to make sure images are displayed without borders
orig_imsetting = iptgetpref('ImshowBorder');
iptsetpref('ImshowBorder', 'tight');
temp1 = onCleanup(@()iptsetpref('ImshowBorder', orig_imsetting));

fun_handles = {@step1,...
    @step2, @step3,...
    @step4, @step5, @application,...
    @demoMATLABTricks};

% Call test harness
runTests(varargin, fun_handles);

%--------------------------------------------------------------------------
% Tests for Step 1: Homography
%--------------------------------------------------------------------------

%%
function step1()
% Test homography

orig_img = imread('portrait.png'); 
warped_img = imread('portrait_transformed.png');

%Choose 4 corresponding points to find the HomoGraphy
imshow(orig_img);
src_pts_nx2  = ginput(4);

imshow(warped_img);
dest_pts_nx2 = ginput(4);

close;

H_3x3 = computeHomography(src_pts_nx2, dest_pts_nx2);

imshow(orig_img);
test_pts_nx2 = ginput(4);
close;
% Apply homography
dest_pts_nx2 = applyHomography(H_3x3, test_pts_nx2);
% test_pts_nx2 and dest_pts_nx2 are the coordinates of corresponding points 
% of the two images, and H is the homography.

% Verify homography 
result_img = showCorrespondence(orig_img, warped_img, test_pts_nx2, dest_pts_nx2);

figure, imshow(result_img);
imwrite(result_img, 'homography_result.png');

%%
testInterface

function step2()
% Test wrapping 

bg_img = im2double(imread('Osaka.png')); 
portrait_img = im2double(imread('portrait_small.png')); 

% Estimate homography
imshow(portrait_img);
portrait_pts = ginput(4);

imshow(bg_img);
bg_pts  = ginput(4);

close;

H_3x3 = computeHomography(portrait_pts, bg_pts);
dest_canvas_width_height = [size(bg_img, 2), size(bg_img, 1)];

% Warp the portrait image
[mask, dest_img] = backwardWarpImg(portrait_img, inv(H_3x3), dest_canvas_width_height);
% mask should be of the type logical
mask = ~mask;
% Superimpose the image
result = bg_img .* cat(3, mask, mask, mask) + dest_img;
% figure, imshow(result);
imwrite(result, 'Van_Gogh_in_Osaka.png');

%%  
function step3()
% Test RANSAC -- outlier rejection

imgs = imread('mountain_left.png'); 
imgd = imread('mountain_center.png');

[xs, xd] = genSIFTMatches(imgs, imgd);
% xs and xd are the centers of matched frames
% xs and xd are nx2 matrices, where the first column contains the x
% coordinates and the second column contains the y coordinates

before_img = showCorrespondence(imgs, imgd, xs, xd);
%figure, imshow(before_img);
imwrite(before_img, 'before_ransac.png');

%Use RANSAC to reject outliers
ransac_n = 50; % Max number of iteractions
ransac_eps = 3; %Acceptable alignment error 

[inliers_id, H_3x3] = runRANSAC(xs, xd, ransac_n, ransac_eps);

after_img = showCorrespondence(imgs, imgd, xs(inliers_id, :), xd(inliers_id, :));
% figure, imshow(after_img);
imwrite(after_img, 'after_ransac.png');

%%
function step4()
% Test image blending

[fish, fish_map, fish_mask] = imread('escher_fish.png');
[horse, horse_map, horse_mask] = imread('escher_horsemen.png');
blended_result = blendImagePair(fish, fish_mask, horse, horse_mask,...
               'blend');
% figure, imshow(blended_result);
imwrite(blended_result, 'blended_result.png');

overlay_result = blendImagePair(fish, fish_mask, horse, horse_mask, 'overlay');
% figure, imshow(overlay_result);
imwrite(overlay_result, 'overlay_result.png');

%%
function step5()
% Test image stitching

% stitch three images
imgc = im2single(imread('mountain_center.png'));
imgl = im2single(imread('mountain_left.png'));
imgr = im2single(imread('mountain_right.png'));

% You are free to change the order of input arguments
stitched_img = stitchImg(imgl, imgc, imgr);
% figure, imshow(stitched_img);
imwrite(stitched_img, 'mountain_panorama.png');

%%
function application()
% Your own panorama
img1 = im2single(imread('1.jpg'));
img2 = im2single(imread('2.jpg'));
img3 = im2single(imread('3.jpg'));
img4 = im2single(imread('4.jpg'));
img5 = im2single(imread('5.jpg'));

stitched_img = stitchImg(img1, img2, img3, img4, img5);
% figure, imshow(stitched_img);
imwrite(stitched_img, 'panorama_1.png');

stitched_img = stitchImg(img1, img2, img3, img4);
% figure, imshow(stitched_img);
imwrite(stitched_img, 'panorama_2.png');
