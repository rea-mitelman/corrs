function rv=turn2row(v)

if size(v,1)>1 && size(v,2)==1
    rv=v';
else
    rv=v;
end