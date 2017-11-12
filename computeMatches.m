function m = computeMatches(f1,f2)
n_blob_f1 = length(f1);
n_blob_f2 = length(f2);
index_array = [];
for i =1:n_blob_f1
    ratio = 0;
    ind=0;
    first_min = intmax;
    second_min = intmax;
    for j = 1:n_blob_f2
        ssd = sum((f2(j,:)-f1(i,:)).^2);
        if (ssd<first_min)
            first_min = ssd;
            ind = j;
            if(second_min == intmax)
                second_min = first_min;
            end
        elseif(ssd<second_min)
            second_min = ssd;
        end  
    end
    ratio = first_min/second_min;
    if(ratio<=0.8)
        index_array = [index_array;ind];
    else
        index_array = [index_array;0];
    end
end
m = index_array;
