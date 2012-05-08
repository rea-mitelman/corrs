function [spk_mat_all, PstPro, Npro, frest_pro, PstSup, Nsup, frest_sup] = ...
	extract_PST_mat( table, isess, iunit, PDmin, PDmax, Tmin, Tmax, ev2take)

% Rest time before reference time (?)
restTmin = -500;
restTmax = 0;

Ntr = 0;PD=0;PDsig = 0;
monks = char(table(isess).fnm);
monks = monks(1); %monkey's letter
fpath = get_path( monks );%all ee files directory
zpst = zeros(1,Tmax-Tmin+1);
trialCounter=0;
validity=[];
Thold = [];
duration=Tmax-Tmin + 1;
restduration=restTmax-restTmin + 1;
% first stage: extracting single trial data;
for j=table(isess).extens(1):table(isess).extens(2) %runs on all files in session
	fnm=sprintf('%s%s.%d.mat',fpath, table(isess).fnm,j); %file name
	fdat = load(fnm);%
	tspikeStr=['Tspike' num2str(table(isess).sp(iunit).id)];
	if isfield(fdat, tspikeStr),
		Tspike = fdat.(tspikeStr);
		flag = 1;
	else
		flag = 0;
	end
	dbgindx = zeros(2,1);
	for ti=1:size(fdat.trials,1)
		trialCounter=trialCounter+1;
		validity(trialCounter)=vTrial(ti,fdat.bhvStat); %#ok<AGROW>
		events=fdat.events_code(fdat.trials(ti,1):fdat.trials(ti,2));
		t=returnTarget(events);
		[evZero, cindx] = returnEvPosition(events, t, ev2take);
		evZero = evZero+fdat.trials(ti,1)-1;
		dbgindx(1) = dbgindx(1) + 1;
		dbgindx(2) = dbgindx(2) + cindx;
		if flag && ~isempty(evZero),
			refTime=fdat.events_time(evZero);
			tmpSpikes=Tspike(Tspike>=refTime+Tmin & Tspike<=refTime+Tmax)-refTime-Tmin+1;
			spikes(trialCounter,:)=[turn2row(time2bin(round(tmpSpikes),Tmax-Tmin+1))]; %#ok<AGROW>
		else
			spikes(trialCounter,:)=zeros(1,duration); %#ok<AGROW>
		end
		handPosition(trialCounter)=fdat.hand_position; %#ok<NASGU>
		targets(trialCounter)=t; %#ok<AGROW>
		% now computing the length of the hold period
		etmp = returnEvPosition(events, t, 'ho');
		etmp = etmp+fdat.trials(ti,1)-1;
		ttmp1 = fdat.events_time(etmp);
		etmp= returnEvPosition(events, t, 'hof');
		etmp = etmp+fdat.trials(ti,1)-1;
		ttmp2 = fdat.events_time(etmp);
		if ~isempty(ttmp1) && ~isempty(ttmp2),
			Thold(trialCounter) = ttmp2-ttmp1; %#ok<AGROW>
			% %             if Thold(trialCounter) > 4000,
			% %                 disp('here');
			% %             end
		else
			Thold(trialCounter) = 0; %#ok<AGROW>
		end
		% now computing the pre-cue activity
		[evZero, cindx] = returnEvPosition(events, t, 'cue');
		evZero = evZero+fdat.trials(ti,1)-1;
		if flag && ~isempty(evZero),
			refTime=fdat.events_time(evZero);
			tmpSpikes=Tspike(Tspike>=refTime+restTmin & Tspike<=refTime+restTmax)-refTime-restTmin+1;
			restspikes(trialCounter,:)=[turn2row(time2bin(round(tmpSpikes),restTmax-restTmin+1))];
		else
			restspikes(trialCounter,:)=zeros(1,restduration);
		end
		
	end%for ti
	% %     disp([ num2str(diff(dbgindx)) ' Mismatching trials in file: ' fnm])
end %of for j



PronIndex=find(table(isess).sp(iunit).trials==1 & validity'); %  & Thold' > 500);%find(x.handPosition==1);
non_pron_ixs= ~(table(isess).sp(iunit).trials==1 & validity'); %  & Thold' > 500);%find(x.handPosition==1);

SupIndex=find(table(isess).sp(iunit).trials==2 & validity'); % & Thold' > 500);%find(x.handPosition==2);

if length(PronIndex) >= 10,
	% 	frest_pro = mean(sum(restspikes(PronIndex,:)'))/restduration*1000;
	frest_pro = mean(sum(restspikes(PronIndex,:),2))/restduration*1000;
else
	frest_pro = nan;
end
if length(SupIndex) > 10,
	% 	frest_sup = mean(sum(restspikes(SupIndex,:)'))/restduration*1000;
	frest_sup = mean(sum(restspikes(SupIndex,:),2))/restduration*1000;
else
	frest_sup = NaN;
end

NTrgVM = 8;
% Computing PD
ax = Tmin:Tmax;
i2pd = find(ax>=PDmin & ax <= PDmax);
% rp=[]; tp=[];
% rp=sum(spikes(PronIndex,i2pd)');
rp=sum(spikes(PronIndex,i2pd),2)';
tp=targets(PronIndex);
[pronPD,p,tet,ratetet,Rwin,Rboot]=computePD(tp,rp,5,15,2);
% if ~isnan( pronPD)
teta=[.5 .25 0 -.25 -.5 -.75 1 .75]*pi;
if length(unique(tp))>= NTrgVM && length(tp) > 15,
	frate = get_rates( tp, rp);
	[ vm, R2, vmp, vmci ] = fitvm( frate, teta);
	if vm(3) > 2*pi,
		disp('Unormal von-mises fit!');
		vm(3) = mod(vm(3),pi);
	end
else
	% 	vm = zeros(1,4);
	vm = nan;
	vmp =1;
end
% Frates = zeros(2,8);
Frates = nan;
Tets = Frates;
Ntr(1) = length(rp);
Frates(1,1:length(ratetet)) = ratetet;
Tets(1,1:length(tet)) = tet;
PD(1) = pronPD;
PDsig(1) = p;
VMfit(1,1:4) = vm;
VMp(1) = vmp;
if ~isnan(PD(1)) && PDsig(1) < 0.05,
	% pdindx = findnearest(teta, PD(1));
	pdindx = findnearest_new( PD(1)); %estimates which of the 8 targets it nearest to PD
	tmpspikes = spikes(PronIndex,:);
	tmptarget = targets(PronIndex);
	Npro = length(find(tmptarget==pdindx));
	PstPro = sum(tmpspikes(tmptarget == pdindx,:));
else
	PstPro = zpst;
	Npro = 0;
end;
%% building the matrix
spk_mat_all=+spikes;
spk_mat_all(non_pron_ixs,:)=NaN;

%%

% rs=sum(spikes(SupIndex,i2pd)');
rs=sum(spikes(SupIndex,i2pd),2)';
ts=targets(SupIndex);
[supPD,p,tet,ratetet,Rwin,Rboot]=computePD(ts,rs,5,15,2);
% if ~isnan( supPD & )
teta=[.5 .25 0 -.25 -.5 -.75 1 .75]*pi;
if length(unique(ts))>= NTrgVM  && length(ts) > 15,
	frate = get_rates( ts, rs);
	[ vm, R2, vmp, vmci ] = fitvm( frate, teta);
	if vm(3) > 2*pi,
		disp('Unormal von-mises fit!');
		vm(3) = mod(vm(3),pi);
	end
else
	% 	vm = zeros(1,4);
	vm = nan;
	vmp =1;
end
Ntr(2) = length(rs);
Tets(2,1:length(tet)) = tet;
PD(2) = supPD;
PDsig(2) = p;
VMfit(2,1:4) = vm;
VMp(2) = vmp;
Frates(2,1:length(ratetet)) = ratetet;


if ~isnan(PD(2)) && PDsig(2) < 0.05,
	%     pdindx = findnearest(teta, PD(2));
	pdindx = findnearest_new( PD(2));
	tmpspikes = spikes(SupIndex,:);
	tmptarget = targets(SupIndex);
	PstSup = sum(tmpspikes(tmptarget == pdindx,:));
	Nsup = length(find(tmptarget==pdindx));
	
else
	PstSup = zpst;
	Nsup = 0;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  filepath = get_path( monks )

filepath = '';
switch (lower( monks)),
	case 'd'
		filepath = 'm:\darma\combinedData_TRQ\';
	case 'g',
		filepath =  'm:\gaya\gayaEdfilesver\';
	case 'v',
		filepath = 'm:\vega\vegaedfiles\';
		% %         filepath = 'd:\vegadata\';
	case 'h'
        % 		filepath = ['D:\Rea' '''' 's_Documents\Prut\Ctx-Thal\data\all_MergedEdFiles\'];
        filepath = '..\..\data\HugoData-CtxThl\AllMergedEdFiles\';
end

if ~exist(filepath,'dir')
	warning(['the direcory ' filepath ' does not exist'])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bool=vTrial(ti,bhvStat)
bool=0;
if bhvStat(ti,1)<=500 && bhvStat(ti,2)<=1500  && abs(bhvStat(ti,5))<=35  && abs(bhvStat(ti,6))<=20 %&& bhvStat(ti,7)>500 &&  bhvStat(ti,7)<1500 &&  bhvStat(ti,11)<=10 &&  bhvStat(ti,12)<=25 &&  bhvStat(ti,13)<=10
	bool=1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function frate = get_rates( tp, rp)

ut = unique(tp);

frate=zeros(1,length(ut));
for ii=1:length(ut),
	frate(ii) = mean(rp(tp == ut(ii)));
end
