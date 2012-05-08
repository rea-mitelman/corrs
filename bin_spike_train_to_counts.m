% IN: spikes in 1ms resulotion
 %         bin_size size of the bin in ms  
function [counts, times] = bin_spike_train_to_counts(spikes, bin_size)
counts =zeros(1, round(spikes(end)/bin_size));
times = zeros(1, round(spikes(end)/bin_size));
start_time=0;
spike_inx =1;
counter = 1;
while (start_time+bin_size <= spikes(end))
    end_time = start_time + bin_size;
    curr_count =0;
    while(spike_inx <= length(spikes) & spikes(spike_inx) < end_time)
        curr_count = curr_count+1;
        spike_inx = spike_inx+1;
    end
    counts(counter) = curr_count;
    times(counter) = start_time;
    counter = counter+1;
    start_time = end_time;
end