function index=time2index(timeVector,specTime)

%This code is relevant for non uniform sampling
% try
%     [stam, index]=min(abs(timeVector-specTime));
% catch
%     index=[];
% end

%for uniform sampling
dt=timeVector(2) -timeVector(1);
t0=timeVector(1);
dI=round((specTime-t0)/dt);
if dI+1>length(timeVector) | dI<0
    index=[];
else
    index=dI+1;
end