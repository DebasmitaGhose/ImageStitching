function [inliers, transf] = ransac(matches, c1, c2, method)
% This code is part of:
%
%   CMPSCI 670: Computer Vision
%   University of Massachusetts, Amherst
%   Instructor: Subhransu Maji

N_match = size(matches,1);
M = size(c2,1);
arr = [];

for x = 1:M
    arr = [arr;([c2(x,1) c2(x,2)])];
end
arr = [arr ones(M,1)];
inliers = [];
max = 0;
%for the number of iterations of RANSAC
for num_iter = 1:40
    random_array = [];
    random_numbers = randi([1, N_match], 1, 1);
    c=1;
    while(c<=3)
        if(matches(random_numbers,1)~=0)
            random_array = [random_array; random_numbers];
            c=c+1;
        end
        random_numbers = randi([1, N_match], 1, 1);
    end
matrix_A = [];
matrix_B = [];

%reverse warp
for x=1:size(random_array,1)
    in = random_array(x);
    x1 = c1(in,1);
    y1 = c1(in,2);
    matrix_B = [matrix_B; [x1,y1]];
    x1_prime = c2(matches(in),1);
    y1_prime = c2(matches(in),2);
    matrix_A = [matrix_A;([x1_prime, y1_prime, 1])];
end

res = matrix_A\matrix_B;
R = arr*res;

number_of_inliers = 0;
best =[];
for x=1:N_match
    if(matches(x,1)~=0)
        x1 = c1(x,1);
        y1 = c1(x,2);
        if((((x1-R(matches(x),1))^2)+((y1-R(matches(x),2))^2))<=5)
            number_of_inliers = number_of_inliers + 1;
            best = [best;x];
        end
    end
end

if(number_of_inliers>max)
    max = number_of_inliers;
    inliers = best;
    transf = res;
    transf = transf';
end
disp(transf);
end


