function [noise_corr p_mat] = noise_correlation(events,  unit_pair, files, TB, TE, ...
    PREDICTOR,BIN_SIZE, GROUP_BINS)
noise_corr = [];
for j=1:size(unit_pair,1)
    first = files(j,1);
    last  =  files(j,2);
    curr_units = unit_pair(j,:);

    % get rasters and spike counts
    counts =[];
    raw_counts = [];
    for k=1:length(curr_units)
        [raw_counts(:,:,k) cut_length num_trials]  = get_count_mat_for_noise_cc( ...
            curr_units(k), events, first,last,TB, TE, BIN_SIZE,PREDICTOR,0);

        N_BIN = floor(size(raw_counts,1)/GROUP_BINS);

        for m=1:N_BIN
            curr= [];
            for l=1:GROUP_BINS
                curr  = [curr,raw_counts((m-1)*GROUP_BINS + l,:,k)];
            end
            counts(m,:,k)  = curr;
        end
    end

    % calc noise correlation
    for k=1:size(counts,1)
        vec1 = counts(k,:,1);
        vec2 = counts(k,:,2);
        [cc  p] = corrcoef(vec1,vec2);
        noise_corr(j,k) =cc(1,2);
        p_mat(j, k) = p(1,2);
    end
end
