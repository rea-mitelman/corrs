% res - raw jpsth
%shift_predict - shift predictor using 1 trial
%psth_pred  - psth predictor
% results are in probability of finding a spike
% at the moment, the shift predictor is cyclic
function [ res shift_predict psth_pred surprise_mat std_mat ] =  ...
    my_JPSTH(cut1, cut2, BIN_SIZE,gauss_filt_std)
% gauss_filt_std is the standard deviation of the gaussian filter for the
% 2d interpulation. By default, or if gauss_filt_std is 0,  no filtering is
% done. 
if nargin>3
	gauss_filt_std=0;
end

NUM_TRIAL = size(cut1,2);
CUT_LENGTH = size(cut1,1);
BIN_NUM = ceil(CUT_LENGTH/ BIN_SIZE);
% count spikes for JPSTH
res = zeros(BIN_NUM,BIN_NUM);
shift_predict = zeros(BIN_NUM,BIN_NUM);

NEXT_REF = find(cut2(:,1));
for i=1:NUM_TRIAL
    INX1 = find(cut1(:,i));
    INX2 = NEXT_REF;
    % get next trails
    use_next = i+1;
    if(i == NUM_TRIAL)
        use_next=1;
    end
    NEXT_REF = find(cut2(:,use_next));
    for j=1:length(INX1)
        % update count matrix
        curr_ref = ceil(INX1(j)/BIN_SIZE);
        trig = ceil(INX2/BIN_SIZE);
        for m=1:length(trig)
            res(curr_ref, trig(m)) =     res(curr_ref, trig(m))+1;
        end
                % update shift predictor matrix
        sp_trig = ceil(NEXT_REF/BIN_SIZE);
        for m=1:length(sp_trig)
            shift_predict(curr_ref, sp_trig(m)) =     shift_predict(curr_ref, sp_trig(m))+1;
        end
                
    end       
end
% remove last bin
shift_predict = shift_predict(1:end-1,1:end-1);
res = res(1:end-1,1:end-1);

% get psth predictor
% psth1 = full(sum(cut1',1));
% psth2 = full(sum(cut2',1));
% %bin_psth1 = bin_raster_to_counts(psth1, BIN_SIZE, 0);
%  bin_psth2 = bin_raster_to_counts(psth2, BIN_SIZE, 0);

bin_cut1 = bin_raster_to_counts(cut1', BIN_SIZE, 0);
bin_cut2 = bin_raster_to_counts(cut2', BIN_SIZE, 0);
bin_psth1 = sum(bin_cut1);
bin_psth2 = sum(bin_cut2);

std1  = std(bin_cut1);
std2 = std(bin_cut2);

std_mat = std1'*std2;

psth_pred = bin_psth1'*bin_psth2; 

norm_factor = NUM_TRIAL; % *BIN_SIZE /1000;
% normalize to probability
psth_pred = psth_pred/(norm_factor^2);
if(length(psth_pred) ~= length(res))
    psth_pred = psth_pred(1:end-1,1:end-1);
end

% LAMDA = psth_pred*norm_factor;
% surprise_mat = 1 - poisscdf( res,LAMDA );
% surprise_mat  = -log(surprise_mat);
surprise_mat =[];
shift_predict  = shift_predict / norm_factor;
res = res/norm_factor;

res  = gauss_filt_2d(res  ,gauss_filt_std);
shift_predict = gauss_filt_2d(shift_predict ,gauss_filt_std);
psth_pred = gauss_filt_2d(psth_pred ,gauss_filt_std);
surprise_mat = gauss_filt_2d(surprise_mat ,gauss_filt_std);
std_mat = gauss_filt_2d(std_mat ,gauss_filt_std);

return;

