function im = mergeImages(im1, im2, transf, method)
% This code is part of:
%
%   CMPSCI 670: Computer Vision
%   University of Massachusetts, Amherst
%   Instructor: Subhransu Maji

if nargin < 4
    method = 'affine';
end

switch method
    case 'affine'
        invtransf = inv(transf(:, 1:2));
        invtransf = [invtransf, -invtransf*transf(:,end)];
    case 'homography'
        invtransf = inv(transf);
end


[h1, w1, ~] = size(im1);
[h2, w2, ~] = size(im2);
im2 = double(im2);

% Coordinates of the four corners of the images
c2 = [1 w2 w2 1; 1 1 h2 h2];

% Transformed coordinates
c2 = transf*[c2; ones(1, size(c2, 2))];
%% Homography
if strcmp(method, 'homography')
    c2 = c2./repmat(c2(3,:), 3, 1);
    c2(3,:) = [];
end

% Get bounds for transformed coordinates
txmin = floor(min(c2(1,:)));
txmax = ceil(max(c2(1,:)));
tymin = floor(min(c2(2,:)));
tymax = ceil(max(c2(2,:)));

% Get bounds for stitched images
xmin = floor(min(1, txmin));
xmax = ceil(max(w1, txmax));
ymin = floor(min(1, tymin));
ymax = ceil(max(h1, tymax));

h = ymax-ymin+1;    w = xmax-xmin+1;
im = zeros(h, w, size(im1,3), 'uint8');
ox = max(0, -xmin+1);
oy = max(0, -ymin+1);

% Paste the two images
im(oy+(1:h1), ox+(1:w1),:) = im1;
[X, Y] = meshgrid(txmin:txmax, tymin:tymax);
X = X(:);   Y = Y(:);
overlap = X>=1 & X<=w1 & Y>=1 & Y<=h1;
X(overlap) = [];    Y(overlap) = [];
c = [X(:), Y(:), ones(numel(X), 1)]';
c = invtransf*c;

if strcmp(method, 'homography')
    c = c./repmat(c(3,:), 3, 1);
    c(3,:) = [];
end

valid = c(1,:)>1 & c(1,:)<=w2 & c(2,:)>1 & c(2,:)<=h2;
sel = 1:size(c, 2); sel = sel(valid);
c = c(:, sel); X = X(sel); Y = Y(sel);

[X1, Y1] = meshgrid(1:w2, 1:h2);
Vqr = interp2(X1, Y1, im2(:,:,1), c(1,:), c(2,:));
Vqg = interp2(X1, Y1, im2(:,:,2), c(1,:), c(2,:));
Vqb = interp2(X1, Y1, im2(:,:,3), c(1,:), c(2,:));

Vqr(Vqr<0) = 0; Vqr(Vqr>255) = 255;
Vqg(Vqg<0) = 0; Vqg(Vqg>255) = 255;
Vqb(Vqb<0) = 0; Vqb(Vqb>255) = 255;
for i=1:numel(X)
    im(oy+Y(i), ox+X(i), :) = uint8([Vqr(i), Vqg(i), Vqb(i)]);
end

im = uint8(im);


