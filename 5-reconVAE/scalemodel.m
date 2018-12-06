% this script is to scale the obj mesh from the database

obj_file_path = [objfolder_path, filesep, '119', filesep, '119.obj'];
output_filepath = 'table.obj';
scalefactor = 0.1;
heightscalefactor = 2.5;

fid = fopen(obj_file_path) ;            
        % Now read the obj file to get all the vertices (no faces)
        v = []; vt = []; vn = []; f = {};
%         txtline = fgetl(fid);
        % parse .obj file
        while 1
            tline = fgetl(fid);
            if ~ischar(tline),   break,   end  % exit at end of file
            ln = sscanf(tline,'%s',1); % line type
            %disp(ln)
            switch ln
                case 'v'   % mesh vertexs
                    v = [v; sscanf(tline(2:end),'%f')'];
                case 'vt'  % texture coordinate
                    vt = [vt; sscanf(tline(3:end),'%f')'];
                case 'vn'  % normal coordinate
                    vn = [vn; sscanf(tline(3:end),'%f')'];
                case 'f'
                    face = strsplit(tline(2:end));
                    f{length(f)+1} = face;
            end
        end
        fclose(fid);
        
        nvers = v*scalefactor;
        nvers(:,2) = nvers(:,2)*heightscalefactor;
        
        fid = fopen(output_filepath,'w');
        %fprintf(fid,texture_line);
        fprintf(fid,'\n');
        for j = 1:size(nvers,1)
            fprintf(fid, 'v  %f  %f  %f \n', nvers(j,3), nvers(j,1), nvers(j,2));
        end
        for j = 1:size(vt,1)
            fprintf(fid, 'vt  %f  %f \n', vt(j,1), vt(j,2));
        end
        for j = 1:size(vn,2)
            fprintf(fid, 'vn  %f  %f  %f \n', vn(3,j), vn(1,j), vn(2,j));
        end
        for j = 1:length(f)
            face = f{j};
            fprintf(fid, 'f  ');
            for v = 1:length(face)
                fprintf(fid,[face{v},'  ']);
            end
            fprintf(fid,'\n');
        end
        fclose(fid);