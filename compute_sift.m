function sift_arr = compute_sift(I, circles, enlarge_factor)
% Modified from Lana Lazebnik's non rotational invariant SIFT 
% using VL-FEAT.
%
% I - image
% circles - Nx3 array where N is the number of circles, where the
%    first column is the x-coordinate, the second column is the y-coordinate,
%    and the third column is the radius
% enlarge_factor is by how much to enarge the radius of the circle before
%    computing the descriptor (a factor of 1.5 or larger is usually necessary
%    for best performance)
% The output is an Nx128 array of SIFT descriptors
% (c) Lana Lazebnik

if ndims(I) == 3
    I = im2double(rgb2gray(I));
else
    I = im2double(I);
end

% parameters (default SIFT size)
num_angles = 8;
num_bins = 4;
num_samples = num_bins * num_bins;
alpha = 9; % smoothing for orientation histogram

if nargin < 3
    enlarge_factor = 1.5;
end

angle_step = 2 * pi / num_angles;
angles = 0:angle_step:2*pi;
angles(num_angles+1) = []; % bin centers

[hgt wid] = size(I);
num_pts = size(circles,1);

sift_arr = zeros(num_pts, num_samples * num_angles);

% edge image
sigma_edge = 1;


[G_X,G_Y]=gen_dgauss(sigma_edge);
I_X = filter2(G_X, I, 'same'); % vertical edges
I_Y = filter2(G_Y, I, 'same'); % horizontal edges
I_mag = sqrt(I_X.^2 + I_Y.^2); % gradient magnitude
I_theta = atan2(I_Y,I_X);
I_theta(isnan(I_theta)) = 0; % necessary????

% make default grid of samples (centered at zero, width 2)
interval = 2/num_bins:2/num_bins:2;
interval = interval - (1/num_bins + 1);
[grid_x grid_y] = meshgrid(interval, interval);
grid_x = reshape(grid_x, [1 num_samples]);
grid_y = reshape(grid_y, [1 num_samples]);

% make orientation images
I_orientation = zeros(hgt, wid, num_angles);
% for each histogram angle
for a=1:num_angles    
    % compute each orientation channel
    tmp = cos(I_theta - angles(a)).^alpha;
    tmp = tmp .* (tmp > 0);
    
    % weight by magnitude
    I_orientation(:,:,a) = tmp .* I_mag;
end

% for all circles
orienStep = 2*pi/36;
orienGrid = -pi+orienStep/2:orienStep:pi;
theta = zeros(num_pts, 1);
for i=1:num_pts
    cx = circles(i,1);
    cy = circles(i,2);
    r = circles(i,3) * enlarge_factor;

    

    % find coordinates of sample points (bin centers)
    grid_x_t = grid_x * r + cx;
    grid_y_t = grid_y * r + cy;
    grid_res = grid_y_t(2) - grid_y_t(1);
    
    % find window of pixels that contributes to this descriptor
    x_lo = floor(max(cx - r - grid_res/2, 1));
    x_hi = ceil(min(cx + r + grid_res/2, wid));
    y_lo = floor(max(cy - r - grid_res/2, 1));
    y_hi = ceil(min(cy + r + grid_res/2, hgt));

    % compute the dominating orientation
    orien = I_theta(y_lo:y_hi, x_lo:x_hi);
    orienDiff = abs(bsxfun(@minus, orien(:), orienGrid));
    [~, oidx] = min(orienDiff, [], 2);
    orienHist = accumarray(oidx, 1);
    [~, maxtheta] = max(orienHist);
    theta(i) = orienGrid(maxtheta);

end
% compute the sift descriptor
circles = [circles, theta];
GRAD = zeros(2, hgt, wid, 'single');
GRAD(1,:,:) = I_mag;
GRAD(2,:,:) = I_theta;
sift_arr = vl_siftdescriptor(GRAD, circles');
sift_arr = single(sift_arr');




function [GX,GY]=gen_dgauss(sigma)

f_wid = 4 * floor(sigma);
G = normpdf(-f_wid:f_wid,0,sigma);
G = G' * G;
[GX,GY] = gradient(G); 

GX = GX * 2 ./ sum(sum(abs(GX)));
GY = GY * 2 ./ sum(sum(abs(GY)));
