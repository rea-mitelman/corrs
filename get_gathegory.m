function cath=get_gathegory(is_tuned,is_resp)
% returns the cathegoty to which a given cell belongs:
% 1: tuned
% 2: not tuned but responsive
% 3: neither tuned nor responsive
if is_tuned
    cath=1;
elseif is_resp
    cath=2;
else
    cath=3;
end
