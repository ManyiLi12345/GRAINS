function [ title, body ] = read_csv( filename )
%READ_CSV 
fid = fopen(filename);

%% read title
tline = fgetl(fid);
sline=regexp(tline,',','split');
col_num = length(sline);
file_data = sline;

lineind = 1;
    
while ~feof(fid)
%     lineind
%     lineind = lineind+1;
%     if lineind==2739
%         oo=0;
%     end
    line_data = cell(1,col_num);
    tline = fgetl(fid);
    sline=regexp(tline,',','split');
    cols = zeros(1,size(sline,2));
    mode = 0; % 0 is outside qoatation, 1 is inside quatation
    ind = 1;
    for i = 1:size(sline,2)
        str = sline{i};
        
        if length(str)>0
            if str(1,1)=='"'
                mode = 1;
                str = str(2:end);
                sline{i} = str;
            end
        end
        
        if length(str)>0
            if str(1,end)=='"'
                mode = 0;
                if length(str)>1
                    str = str(1:end-1);
                else
                    str = '';
                end
                sline{i} = str;
            end
        end
        
        cols(1,i) = ind;
        if ~mode
            ind = ind+1;
        end
    end
    
    %% merge cells
    for i = 1:col_num
        idx = find(cols==i);
        str = [];
        for j = 1:size(idx,2)
            str = [str ',' sline{idx(1,j)}];
        end
        line_data{i} = str(2:end);
        if size(idx,2)<1
            line_data{i} = '';
        end
    end
    c_num = size(file_data,1);
    for i = 1:size(line_data,2)
        file_data{c_num+1,i} = line_data{i};
    end
end

title = file_data(1,:);
body = file_data(2:end,:);

fclose(fid);
end

