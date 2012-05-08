function  indx = findnearest_new( PD)

TargN2PI(1) = pi/2;
TargN2PI(2) = pi/4;
TargN2PI(3) = 0;
TargN2PI(4) = -pi/4;
TargN2PI(5) = -pi/2;
TargN2PI(6) = -3*pi/4;
TargN2PI(7) = pi;
TargN2PI(8) = 3*pi/4;

tmppd = PD;
if tmppd  > 1.25*pi,
    tmppd = tmppd-2*pi;
end
indx = find(abs(TargN2PI - tmppd) == min(abs(TargN2PI - tmppd) ));


