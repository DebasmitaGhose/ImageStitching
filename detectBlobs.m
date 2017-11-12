function blobs = detectBlobs(im, param)
% This code is part of:
%
%   CMPSCI 670: Computer Vision
%   University of Massachusetts, Amherst
%   Instructor: Subhransu Maji

% Input:
%   IM - input image
%
% Ouput:
%   BLOBS - n x 4 array with blob in each row in (
% Dummy - returns a blob at the center of the imagx, y, radius, score)
im = im2double(im);
im = rgb2gray(im);
[height, width]= size(im); %h,w

n=20;
scaleSpace = zeros(height, width, n);
i=2;
k=1;
sc = zeros(n);

%building the laplacian scale space
while(k<=n)
    filt = (i*i)*fspecial('log',2*ceil(3*i)+1,i);
    lap_filt = imfilter(im,filt,'same','replicate');
    scaleSpace(:,:,k) = (lap_filt).^2;
    norm = scaleSpace(:,:,k);
    sc(k) = i;
    k=k+1;
    i = i*1.2;
    %disp(scaleSpace(:,:,k));
end

%non - maximum supression
ord2 = ones(height,width,n);
ord_a = ordfilt2(scaleSpace(:,:,1),9,ones(3,3));
ord_b = ordfilt2(scaleSpace(:,:,2),9,ones(3,3));
ord2(:,:,1) = max(ord_a(:,:), ord_b(:,:));
for j = 2:n-1
    ord_1 = ordfilt2(scaleSpace(:,:,j-1),9,ones(3,3));
    ord_2 = ordfilt2(scaleSpace(:,:,j),9,ones(3,3));
    ord_3 = ordfilt2(scaleSpace(:,:,j+1),9,ones(3,3));
    ord2(:,:,j) = max(ord_1(:,:), ord_2(:,:));
    ord2(:,:,j)= max(ord2(:,:,j),ord_3(:,:));
end
ord_c = ordfilt2(scaleSpace(:,:,n-1),9,ones(3,3));
ord_d = ordfilt2(scaleSpace(:,:,n),9,ones(3,3));
ord2(:,:,10) = max(ord_c(:,:), ord_d(:,:));

ord2 = ord2.*(ord2 == scaleSpace);

%finding out the location, size and the intensity value of the blob
row = [];
col = [];
radius = [];
val = [];
th = 0.001;
ord2(ord2<th)=0;
for i = 1:n
    [r, c, value] = find(ord2(:,:,i));
    blob_no = length(r);
    rad = sc(i).*sqrt(2);
    rad = repmat(rad, blob_no,1);
    row = [row;r];
    col = [col;c];
    val = [val;value];
    radius = [radius;rad];    
end

blobs = [col, row, radius, val];
    
    
            


%blobs = round([size(im,2)*0.5 size(im,1)*0.5 0.25*min(size(im,1), size(im,2)) 1]);