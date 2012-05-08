function diagon=plot_JPST(mat1,mat2,raw_jpsth,psth_pred,std_mat,Tmin,Tmax,bin_size,gauss_filt_std)

raw_jpsth = gauss_filt_2d(raw_jpsth,gauss_filt_std);
psth_pred = gauss_filt_2d(psth_pred ,gauss_filt_std);
std_mat =  gauss_filt_2d(std_mat ,gauss_filt_std);

shad_type='flat';
t=[Tmin+bin_size/2:bin_size:Tmax-bin_size/2]/1000;
psth1=mean(bin_raster_to_counts(mat1', bin_size, 0));
psth2=mean(bin_raster_to_counts(mat2', bin_size, 0));
subtracted_jpsth=raw_jpsth-psth_pred;
norm_jpsth=subtracted_jpsth./std_mat;
jpsth_subs_diag=diag(subtracted_jpsth);
jpsth_norm_diag=diag(norm_jpsth);

% jpsth_std_diag=diag(std_mat)/size(mat1,2)^.5;

clf

subplot(2,3,1)
pcolor(t,t,raw_jpsth)
% shading interp
shading (shad_type)
colorbar
xlabel('ctx. time (s)')
ylabel('thal. time (s)')
title('Raw JPSTH')
axis square
hold on
% plot(t,t,':')
plot([0 0],[-1 1],'--k',[-1 1],[0 0] ,'--k','LineWidth',2)
text(2.4,0,'spikes^2/s^2','Rotation',90,'HorizontalAlignment','center')

subplot(2,3,2)
pcolor(t,t,subtracted_jpsth)
% shading interp
shading (shad_type)
colorbar
xlabel('ctx. time (s)')
ylabel('thal. time (s)')
title('compensated JPSTH')
axis square
hold on
% plot(t,t,':')
plot([0 0],[-1 1],'--k',[-1 1],[0 0] ,'--k','LineWidth',2)
text(2.4,0,'spikes^2/s^2','Rotation',90,'HorizontalAlignment','center')

subplot(2,3,3)
pcolor(t,t,norm_jpsth)
% shading interp
shading (shad_type)
colorbar
xlabel('ctx. time (s)')
ylabel('thal. time (s)')
title('Normalized JPSTH')
axis square
hold on
plot(t,t,':')
text(2.4,0,'spikes^2/s^2','Rotation',90,'HorizontalAlignment','center')

subplot(2,4,5)
bar(t,jpsth_subs_diag)
xlabel('time(sec)')
ylabel('Spk^2/s^2')
title('JPSTH subtracted diagonal')
xlim([-inf inf])

subplot(2,4,6)
bar(t,jpsth_norm_diag)
xlabel('time(sec)')
ylabel('Spk^2/s^2')
title('JPSTH normalized diagonal')
xlim([-inf inf])

subplot(2,4,7)
bar(t,psth1)
xlabel('time (s)')
title('ctx PSTH')
xlim([-inf inf])

subplot(2,4,8)
bar(t,psth2)
xlabel('time (s)')
title('thal PSTH')
xlim([-inf inf])

diagon=jpsth_subs_diag;