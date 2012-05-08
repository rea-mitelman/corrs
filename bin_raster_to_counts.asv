% for each row in the raster count the number of spikes in each bin
% IN: raster each row is a spike train with 1 ms resolution
%         bin_size in ms
function [counts] = bin_raster_to_counts(raster, bin_size, do_slide_win)
counts =[];

if(~exist('do_slide_win')  | ~do_slide_win)
    start_t=1;
    while (start_t+bin_size -1<= size(raster,2))
        end_t =start_t+bin_size-1;
        counts(:,end+1) = full(sum(raster(:,start_t:end_t)',1));
        start_t = end_t+1;
    end
else % bin raster by sliding window (move average)

    L = size(raster,2) - bin_size+1;
    counts = zeros(size(raster,1), L);
    for i=1:L
        if(i==1)
            counts(:,i) = full(sum(raster(:,i:i+bin_size-1)',1));
        else
            counts(:,i) = counts(:,i-1);
            counts(:,i) = counts(:,i-1)  -  full(raster(:,i-1)) + full(raster(:,i+bin_size-1));
        end

    end

end



