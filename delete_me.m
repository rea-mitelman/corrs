base='G:\users\ream\Prut\Yolanda\Data\YolandaData\';
table_file=[base '\Yolanda_Offline.mat'];
yol_tab.table=table_text2mat('G:\users\ream\Prut\Yolanda\Data\YolandaData\Yolanda_offline_all.txt','G:\users\ream\Prut\Yolanda\Data\YolandaData\y150212\MergedEdFiles\');


for i_sess=1:length(yol_tab.table)
    for i_subsess=1:length(yol_tab.table(i_sess).sp)
        if yol_tab.table(i_sess).sp(i_subsess).id<200
            yol_tab.table(i_sess).sp(i_subsess).loc='Thal';
        else
            yol_tab.table(i_sess).sp(i_subsess).loc='CTX';
        end
        yol_tab.table(i_sess).sp(i_subsess).resp=true;
    end
end
save(table_file,'-struct','yol_tab')
