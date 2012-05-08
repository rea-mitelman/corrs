function copy_all_ee2dir(base_dir,target_dir)
% copy_all_ee2dir(base_dir,target_dir)
% copies all data from scattered directories to a single one
% base_dir - a full path of the location in which all recording days
% subdirectories, in the fallowing format:
% "base_dir" \ "session name" \ MergedEdFiles
% when "session name" is the name of the session, comprised of the monkey
% letter (e.g. h for Hugo), and the date in ddmmyy format.
% target_dir - the full path of the target directory

if ~exist(target_dir)
    mkdir(target_dir);
    disp(['creating ' target_dir])
end

alldirs=dir(base_dir);

for ii=1:length(alldirs)
    if ~alldirs(ii).isdir
        continue
    end
    full_org=[base_dir '\' alldirs(ii).name '\MergedEdFiles'];
    if exist(full_org,'dir')
        copyfile([full_org '\*.*.mat'],target_dir)
        disp(['Copying files from: ' full_org ' to: ' target_dir]);
    end
end
