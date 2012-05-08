%% tab2mat_trial
clear
close all
base=['D:\Rea' '''' 's_Documents\Prut\Ctx-Thal\'];
fnm=[base 'data\HugoCtxThlOffline.txt'];
indir=[base 'data\all_MergedEdFiles\'];
output_dir=[base 'results\'];

PDmin=100;
PDmax=500;
Tmin=-1000;
Tmax=1000;
ev2take='to';

bin_size=100;
do_plot=false;
res_subsess={
	'h22002ee'
	'h22003ee'
	'h21902ee'
	'h21906ee'
	'h21908ee'};

non_res_subsess={
	'h22005ee'
	'h21904ee'};

gauss_filt_std=1;
%%
%electrode locations should be encoded in the table data!
ctx_elects=1:3;
thal_elects=4;
tab = table_text2mat( fnm, indir);
all_comp_jpsth.responsive=zeros(0,0,0);all_comp_jpsth.non_responsive=zeros(0,0,0);
diagon.responsive=zeros(0,0);diagon.non_responsive=zeros(0,0);
counter.responsive.ctx=0;
counter.non_responsive.ctx=0;
counter.responsive.thal=0;
counter.non_responsive.thal=0;

%%

for isess=1:length(tab)
	id.ctx=[];id.thal=[];
	all_mats.ctx={};all_mats.thal={};
	res_flag = any(strcmp(res_subsess,tab(isess).fnm));
	if res_flag 
		res_field='responsive';
	else
		res_field='non_responsive';
	end
% for isess=1
	for iunit=1:length(tab(isess).sp)
		this_unit=tab(isess).sp(iunit).id;
		if ismember(get_elec_num(this_unit),ctx_elects)
			location='ctx';
		elseif ismember(get_elec_num(this_unit),thal_elects)
			location='thal';
		else
			error('could not find electrode location')
		end
		all_mats.(location){end+1}= extract_PST_mat( tab, isess, iunit, PDmin, PDmax, Tmin, Tmax, ev2take);
		id.(location)(end+1)=this_unit;
		counter.(res_field).(location)=counter.(res_field).(location)+1;
	end
	
	for i_ctx=1:length(all_mats.ctx)
		for i_thal=1:length(all_mats.thal)
			
			[ctx_mat,thal_mat]=get_non_NaN_trials(all_mats.ctx{i_ctx}',all_mats.thal{i_thal}');
			if isempty(ctx_mat) || isempty(thal_mat) || sum(thal_mat(:))/length(thal_mat(:))*1000 < 0.5 || sum(ctx_mat(:))/length(ctx_mat(:))*1000 < 0.5
				continue
			end
			
			
			[res, shift_predict, psth_pred, surprise_mat, std_mat ] =  my_JPSTH(ctx_mat, thal_mat, bin_size,gauss_filt_std);
			
			all_comp_jpsth.(res_field)(:,:,end+1)=gauss_filt_2d (res-psth_pred,gauss_filt_std);
			diagon.(res_field)(:,end+1)=diag(all_comp_jpsth.(res_field)(:,:,end));

			if do_plot
				plot_JPST(ctx_mat,thal_mat,res,psth_pred,std_mat,Tmin,Tmax,bin_size, gauss_filt_std);
				strng=['sess-' tab(isess).fnm ' ctx-' num2str(id.ctx(i_ctx)) ' thal-' num2str(id.thal(i_thal)) '  ' num2str(size(ctx_mat,2)) ' trials ' res_field '.eps'];
				suptitle(strng)
				file_dest=[output_dir strng];
				saveas(gca,file_dest,'psc2')
			end
			% 			pause
			
		end
		
		
	end
	
end
save([output_dir 'all_jpsth'],'all_comp_jpsth','diagon');

% keyboard
%%
load([output_dir 'all_jpsth'])
figure(1)
t=[Tmin+bin_size/2:bin_size:Tmax-bin_size/2]/1000;
close all
% mean_jpsth_resp=mean(all_comp_jpsth.responsive,3);
% mean_jpsth_no_resp=mean(all_comp_jpsth.non_responsive,3);
% sem_jpsth_resp=std(all_comp_jpsth.responsive,[],3)/sqrt(size(all_comp_jpsth.responsive,3));
% sem_jpsth_no_resp=std(all_comp_jpsth.non_responsive,[],3)/sqrt(size(all_comp_jpsth.non_responsive,3));

mean_jpsth_resp=var((all_comp_jpsth.responsive),[],3);
mean_jpsth_no_resp=var((all_comp_jpsth.non_responsive),[],3);
sem_jpsth_resp=std(all_comp_jpsth.responsive,[],3)/sqrt(size(all_comp_jpsth.responsive,3));
sem_jpsth_no_resp=std(all_comp_jpsth.non_responsive,[],3)/sqrt(size(all_comp_jpsth.non_responsive,3));

mean_jpsth_resp_diag=diag(mean_jpsth_resp);
mean_jpsth_no_resp_diag=diag(mean_jpsth_no_resp);
sem_jpsth_resp_diag=diag(sem_jpsth_resp);
sem_jpsth_no_resp_diag=diag(sem_jpsth_no_resp);

caxis_val(1)=min([mean_jpsth_resp(:) ; mean_jpsth_no_resp(:)]);
caxis_val(2)=max([mean_jpsth_resp(:) ; mean_jpsth_no_resp(:)]);

subplot(2,2,1)
pcolor(t,t,mean_jpsth_resp)
hold on

plot([0 0],[-1 1],'--k',[-1 1],[0 0] ,'--k','LineWidth',2)
shading flat
colorbar
xlabel('ctx. time (s)')
ylabel('thal. time (s)')
title('Mean JPSTH of SCP responsive areas')
axis square
caxis(caxis_val)
text(2.4,0,'spikes^2/s^2','Rotation',90,'HorizontalAlignment','center')

subplot(2,2,2)
pcolor(t,t,mean_jpsth_no_resp)
hold on
plot([0 0],[-1 1],'--k',[-1 1],[0 0] ,'--k','LineWidth',2)

shading flat
colorbar
xlabel('ctx. time (s)')
ylabel('thal. time (s)')
title('Mean JPSTH of SCP non-responsive areas')
axis square
caxis(caxis_val)
text(2.4,0,'spikes^2/s^2','Rotation',90,'HorizontalAlignment','center')

subplot(2,2,3)
errorbar_patch(t,mean_jpsth_resp_diag,sem_jpsth_resp_diag);
title('diagonal of SCP responsive')
axis([-inf inf -.1 .1])

subplot(2,2,4)
errorbar_patch(t,mean_jpsth_no_resp_diag,sem_jpsth_no_resp_diag);
title('diagonal of SCP non-responsive')
axis([-inf inf -.1 .1])
saveas(gca,[output_dir 'mean_jpsth.eps'],'psc2')
% iunit=7;isess=1;
%
% all_unit_mats{iunit}= extract_PST_mat( tab, isess, iunit, PDmin, PDmax, Tmin, Tmax, ev2take);
%%
figure(2)

scp_resp=fieldnames(diagon);
for ii=1:2
	subplot(2,2,ii)
	plot(t,mean(abs(diagon.(scp_resp{ii})),2))
	xlabel('time(s)')
	ylabel('spike^2')
	title(['mean of rectified JPSTH diagonal , ' scp_resp{ii}])
end

for ii=1:2
% 	lill_p=zeros(1,size(diagon.(scp_resp{ii}),1));
	subplot(2,2,ii+2)
	plot(t,mad(diagon.(scp_resp{ii}),1,2))
	xlabel('time(s)')
	ylabel('spike^2')
	title(['MAD of JPSTH diagonal ' scp_resp{ii}])
end
saveas(gca,[output_dir 'diagonal_jpsth_variability'],'jpg')


%%
t_cut_edges=[-100 300]/1000;
t_cut_ixs = t>=t_cut_edges(1) & t<=t_cut_edges(2);
t_cut = t(t_cut_ixs);
figure(3);clf;
n_mads=3;
caxis_val=[-0.4,0.4];
for ii=1
	cut_jpsth=diagon.(scp_resp{ii})(t_cut_ixs,:);
	sum_cut_jpsth.(scp_resp{ii})=sum(cut_jpsth);
	median_sum=median(sum_cut_jpsth.(scp_resp{ii}));
	mad_sum=mad(sum_cut_jpsth.(scp_resp{ii}),1);
	[histogram hist_ixs]=hist(sum_cut_jpsth.(scp_resp{ii}),35);
	
	
	%fitting gaussian
	fo_ = fitoptions('method','NonlinearLeastSquares','Lower',[-Inf -Inf    0]);
	ft_ = fittype('gauss1');
	cf_ = fit(hist_ixs',histogram',ft_,fo_);

	figure(ii*2+1)
	clf
	% 	subplot(1,2,ii)
	hold on
	bar(hist_ixs,histogram)
	yl=ylim;
	plot(cf_,'fit')
	
	plot(median_sum*ones(1,2),[0 yl(2)],'k',...
		+mad_sum*n_mads+median_sum*ones(1,2),[0 yl(2)],'--k',...
		-mad_sum*n_mads+median_sum*ones(1,2),[0 yl(2)],'--k','LineWidth',4)
		xlim([-inf inf])
		
		
		set(gca,'FontSize',15)%,'LineWidth',3)
		
% 	title(['sum JPSTH between ' num2str(t_cut_edges(1)*1000) ' and ' num2str(t_cut_edges(2)*1000)  ' msec. ' scp_resp{ii}])
	
	xlabel('spikes^2')
	ylabel('number of pairs')
	% 	if ii==2
	legend('Histogram','Gaussian Fit','Median',['Median +/- ' num2str(n_mads) ' mads'],'location','NorthEast')
	% 	end
	
	figure(4);
	clf
	low_dev_ixs=sum_cut_jpsth.(scp_resp{ii}) < (-mad_sum*n_mads+median_sum);
	high_dev_ixs=sum_cut_jpsth.(scp_resp{ii}) > (mad_sum*n_mads+median_sum);
	
	low_dev_jpsth=mean(all_comp_jpsth.(scp_resp{ii})(:,:,low_dev_ixs),3);
	high_dev_jpsth=mean(all_comp_jpsth.(scp_resp{ii})(:,:,high_dev_ixs),3);
	subplot(1,2,ii*2-1)
	pcolor(t,t,low_dev_jpsth)
	hold on
	plot([0 0],[-1 1],'--k',[-1 1],[0 0] ,'--k','LineWidth',2)

	shading flat
	axis square
	title(['JPSTH of low deviant, ' scp_resp{ii}] )
	colorbar
% 	axis([-inf,inf,-inf,inf])
	
	caxis(caxis_val)
	xlabel('ctx. time (s)')
	ylabel('thal. time (s)')
	text(1.6,0,'spikes^2/s^2','Rotation',90,'HorizontalAlignment','center')

	
	subplot(1,2,ii*2)
	pcolor(t,t,high_dev_jpsth)
	hold on
	plot([0 0],[-1 1],'--k',[-1 1],[0 0] ,'--k','LineWidth',2)

	shading flat
	axis square
	title(['JPSTH of high deviant, ' scp_resp{ii}] )
	colorbar
% 	axis([-inf,inf,-inf,inf])

	caxis(caxis_val)
	xlabel('ctx. time (s)')
	ylabel('thal. time (s)')
	text(1.6,0,'spikes^2/s^2','Rotation',90,'HorizontalAlignment','center')

	
end
%%
figure(3)
saveas(gca,[output_dir 'cut_vec_distrib.eps'],'psc2')

figure(4)
saveas(gca,[output_dir 'deviant_mean_jpsth.eps'],'psc2')

%%

% [h,p]=kstest2(sum_cut_jpsth.non_responsive,sum_cut_jpsth.responsive)
% % [h,p]=lillietest(sum_cut_jpsth.responsive,[],[],1e-4)
% % [h,p]=lillietest(sum_cut_jpsth.non_responsive,[],[],1e-4)
% [h,p]=chi2gof(sum_cut_jpsth.responsive)
% [h,p]=chi2gof(sum_cut_jpsth.non_responsive)

