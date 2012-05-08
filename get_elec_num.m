function elect=get_elec_num(unit)
if ~isequal (size(unit),[1 1])
	error('unit should be a scalar')
end

if unit>=100 %offline
	elect=floor(unit/100);
elseif unit>=1
	elect=ceil(unit/4);
else
	error('unit must be a positive number')
end