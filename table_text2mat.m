function table = table_text2mat( fnm, indir )

indx = 1;
endoffile = 0;
fid = fopen(fnm, 'r');
tline = fgetl(fid);
if ~ischar(tline), endoffile = 1, end

while ~endoffile,
    pos = findstr(tline, '%');
    if ~isempty(pos),
        tline = tline(1:min(pos)-1);
    end

    sessnm = sscanf(tline,'%s');
 
    extens= get_file_range( indir, sessnm );
    tline = fgetl(fid);
    pos = findstr(tline, '%');
    if ~isempty(pos),
        tline = tline(1:min(pos)-1);
    end
    table(indx).fnm = sessnm;
    table(indx).extens = extens;
    
    Ntr = sscanf(tline,'%d');
    tline = fgetl(fid);
    spindx = 1;
    while ~isempty(tline) & ( ~isletter(tline(1))) & ~endoffile,
        pos1 = findstr(tline,'[');
        spid = str2num(tline(1:pos1-1));
        pos2 = findstr(tline,']');
        spdef = tline(pos1:pos2);
        excl = [double(']') double('[') double(' ')];
        pos2exc = ismember( double( spdef),excl);
        spdef = spdef( find( pos2exc ==0 ));        
        table(indx).sp(spindx).id = spid;
        table(indx).sp(spindx).grd = [];
        table(indx).sp(spindx).trials = zeros(Ntr,1);
        if findstr(spdef,'999')
            table(indx).sp(spindx).trials = ones(Ntr,1);
            spindx=spindx+1;
        else
            pos3=findstr(spdef,'|');
            if length(pos3)~=2
                error(['non appropriate number of | in ' sessnm ' unit ' num2str(spid)])
            end
            pos3=[0 pos3 length(spdef)+1];
            for j=1:3
                spdef_sub=spdef(pos3(j)+1:pos3(j+1)-1);
                if ~isempty(spdef_sub)
                    pos4=findstr(spdef_sub,':');
                    if isempty(pos4)
                        pos5=findstr(spdef_sub,',');
                        pos5=[0 pos5 length(spdef_sub)+1];
                        for k=1:length(pos5)-1
                            tmp=spdef_sub(pos5(k)+1:pos5(k+1)-1);
                            pos6=findstr(tmp,'-');
                            range=str2num(tmp(1:pos6-1)):str2num(tmp(pos6+1:end));
                            table(indx).sp(spindx).trials(range)=j;                            
                        end
                    else %if found ':'
                        pos4=[0 pos4 length(spdef_sub)+1];
                        for m=1:length(pos4)-1
                            tmp1=spdef_sub(pos4(m)+1:pos4(m+1)-1);
                            pos5=findstr(tmp1,',');
                            pos5=[0 pos5 length(tmp1)+1];
                            for k=1:length(pos5)-1
                                tmp2=tmp1(pos5(k)+1:pos5(k+1)-1);
                                pos6=findstr(tmp2,'-');
                                range=str2num(tmp2(1:pos6-1)):str2num(tmp2(pos6+1:end));
                                table(indx).sp(spindx).trials(range)=j+m/10;                                
                            end %of for k
                        end %of for m
                    end% of if ':'
                end %of isempty(spdef)
            end %of for j
            spindx=spindx+1;
        end %of if 999
        
        
        %        pos3 = findstr(spdef,':');
        %        if isempty( pos3), % a single spike was defined
        %             table(indx).sp(spindx).id = spid;
        %             table(indx).sp(spindx).trials = get_trials( spdef,Ntr);
        %             table(indx).sp(spindx).grd = [];
        %             spindx = spindx+1;
        %         else
        %             pos_start = 1;
        %             pos3 = [pos3 length(spdef)];
        %             for j=1:length(pos3),
        %                 sp_subdef = spdef(pos_start+1:pos3(j)-1);
        %                 pos_start = pos3(j);
        %                 table(indx).sp(spindx).id = spid + j/10;
        %                 table(indx).sp(spindx).trials = get_trials( sp_subdef,Ntr);
        %                 table(indx).sp(spindx).grd = [];
        %                 spindx = spindx+1;
        %             end;
        %         end;
        tline = fgetl(fid);
        if isempty(tline) | ~ischar(tline),
            endoffile = 1;
        end;
    end;
    indx = indx+1;
end
fclose(fid);



function     extens= get_file_range( indir, sessnm )

fullpath = [indir sessnm '.*'];
tmp = dir(fullpath);
n_files=length(tmp);
if n_files==0
    disp('wrong number of files')
    error
end

for i=1:n_files,
    fname = char(tmp(i).name);
    pos = findstr(fname,'.');
    e(i)=str2num(fname(pos(1)+1:pos(2)-1));
end;
extens(1) = min(e);
extens(2) = max(e);


function  trials = get_trials( spdef, Ntr);

excl = [double(']') double('[') double(' ')];
pos2exc = ismember( double( spdef),excl);
spdef = spdef( find( pos2exc ==0 ));
trials = zeros(Ntr,1);
if findstr(spdef,'999') % all trials are taken
    trials = ones(Ntr,1);
elseif findstr(spdef(1), '~'), % exclusion definition
    trials = ones(Ntr,1);
    spdef = spdef(find(double(spdef) ~= double('~')));
    pos = findstr( spdef,',');
    pos = [pos length(spdef)];
    pos_start = 1;
    for j=1:length(pos),
        spdef_subset = spdef(pos_start:pos(j));
        ipos= findstr(spdef_subset,'-');
        if isempty(ipos), % single value
            trindx1 = str2num( spdef_subset);
            trindx2= trindx1;
        else
            trindx1 = str2num( spdef_subset(1:ipos-1));
            trindx2 = str2num( spdef_subset(ipos+1:length(spdef_subset)));
        end;
        trials(trindx1:trindx2) = 0;
        pos_start = pos(j)+1;
        
    end;
else, % inclusion definition
    pos = findstr( spdef,',');
    pos = [pos length(spdef)];
    pos_start = 1;
    for j=1:length(pos),
        spdef_subset = spdef(pos_start:pos(j));
        ipos= findstr(spdef_subset,'-');
        if isempty(ipos), % single value
            trindx1 = str2num( spdef_subset);
            trindx2= trindx1;
        else
            trindx1 = str2num( spdef_subset(1:ipos-1));
            trindx2 = str2num( spdef_subset(ipos+1:length(spdef_subset)));
        end;
        trials(trindx1:trindx2) = 1;
        pos_start = pos(j)+1;
        
    end;
end;
msgbox('remember to save the table!')
