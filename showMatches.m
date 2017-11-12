function showMatches(im1, im2, c1, c2, matches)
% This code is part of:
%
%   CMPSCI 670: Computer Vision
%   University of Massachusetts, Amherst
%   Instructor: Subhransu Maji

c1 = c1';   c2 = c2';

if size(im1, 1) > 1
    im1 = rgb2gray(im1);
end
if size(im2, 1) > 1
    im2 = rgb2gray(im2);
end

% Concatenate images
[h1,w1,~] = size(im1);
[h2,~,~] = size(im2);
if h1 > h2
    im2 = padarray(im2, [h1-h2 0], 'post');
else
    im1 = padarray(im1, [h2-h1 0], 'post');
end
imc = cat(2, im1, im2);

figure;
imshow(imc);
hold on; axis image off;
c2(1,:) = c2(1,:) + w1; % adjust the x coordinate by width
plot(c1(1,:), c1(2,:), 'r.');
plot(c2(1,:), c2(2,:), 'r.');
for i = 1:length(matches)
    if matches(i) > 0, % ignore zero matches
        line([c1(1,i) c2(1,matches(i))], ([c1(2,i) c2(2,matches(i))]));
    end
end
