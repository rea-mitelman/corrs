function [p,R,Rboot]=btstrpDir(targets, rates, Nbtstrp,minTrialsPerTarget)
%[p,R,Rboot]=btstrpDir(targets, rates, Nbtstrp)

if length(unique(targets))== length(targets),
    p = 1;
    R=0;
    Rboot = 0;
    return
end

tetas=[90 45 0 -45 -90 -135 180 135]*pi/180;
%Nbtstrp=4000;

%Dir=Data.dir;
%Rates=Data.rates;
U=unique(targets);
lu=length(U);
% P=randperm(Nbtstrp*lu);
% P=mod(P,lu);
% P(find(P==0))=lu;
% PP=P;
n=length(rates);
randP=round(rand(n*Nbtstrp,1)*n+0.5); 
indx=reshape(randP,[],Nbtstrp);
bootRates=rates(indx);
count=1;
index=[];
tCount=0;
for i=1:lu
     tmp=find(targets==U(i));
     ntmp=length(tmp);
     if ntmp>=minTrialsPerTarget
         index=[index U(i)];
         tCount=tCount+1;
         tmpRates=rates(tmp);
        M(tCount)=mean(tmpRates);        
        bM(tCount,:)=mean(bootRates(count:count+ntmp-1,:));        
     end     
     count=count+ntmp;     
end
teta=tetas(index);
Rx=cos(teta)*M';
Ry=sin(teta)*M';
%R=sqrt(Rx.^2+Ry.^2);
R=sqrt(Rx.^2+Ry.^2)/sum(M);
%PP8=reshape(PP,8,[]);
Rx=cos(teta)*bM;
Ry=sin(teta)*bM;
%Rboot=sqrt(Rx.^2+Ry.^2);
Rboot=sqrt(Rx.^2+Ry.^2)./sum(bM);
p=length(find(Rboot>R))/Nbtstrp;
%figure, hist(Rboot,50), hold on, plot([R R],[0 Nbtstrp/10],'r')
