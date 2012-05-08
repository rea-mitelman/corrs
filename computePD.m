function [PD,p,x,y,R,Rboot]=computePD(targets,rates, minTargets, minTotTrials, minTrialsPerTarget)
% [PD,p,x,y,R,Rboot]=computePD(targets,rates,minTrials)

if isempty(rates)| sum(rates) == 0,
    PD = nan; p = 1; x=[]; y=[]; R=[]; Rboot=[];
    return;
end

teta=[.5 .25 0 -.25 -.5 -.75 1 .75]*pi;
u=unique(targets);
lu=length(u);
x=[];
y=[];
count=0;
nTrials=0;
for j=1:lu
    tmp=find(targets==u(j)); tmp=tmp(~isnan(rates(tmp)));
    if length(tmp)>=minTrialsPerTarget
        count=count+1;
        x(count)=teta(u(j));
        y(count)=mean(rates(tmp));
        nTrials=nTrials+length(tmp);
    end    
end
if count>=minTargets & nTrials>=minTotTrials
    cx=cos(x);
    sx=sin(x);
    mcx=sum(y.*cx)/sum(y);
    msx=sum(y.*sx)/sum(y);
    PD=atan(msx/mcx)+(mcx<0)*pi;
else
    PD=nan;
end
[p,R,Rboot]=btstrpDir(targets, rates, 5000,2);