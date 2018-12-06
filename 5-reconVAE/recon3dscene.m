function recon3dscene( rdata, output_folder, sizescale, objfolder_path )
% output_folder = 'scene3';
%%
% Get the body of the csv file. This csv file has all the catogeries
[model_category_title, model_category_body ] = read_csv('models.csv'); % read the body and titles of the csv file
model_id = model_category_body(:,1);
model_front = model_category_body(:,2);

%% get the obj file from the folder
for i = 1:length(rdata.id_list)
    folder = rdata.id_list{i};
    if (folder)
        new_path = fullfile(objfolder_path, rdata.id_list{i});
        obj_file_path = dir(fullfile(new_path,'*.obj'));
        obj_file_path = fullfile(obj_file_path.folder, obj_file_path.name);
        
        fid = fopen(obj_file_path);   
        % Now read the obj file to get all the vertices (no faces)
        v = []; vt = []; vn = []; f = {};
        % parse .obj file
        while 1
            tline = fgetl(fid);
            if ~ischar(tline),   break,   end  % exit at end of file
            ln = sscanf(tline,'%s',1); % line type
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
        
        cent = rdata.obblist(1:3,i);
        gfront = rdata.obblist(4:6,i);
        gup  = rdata.obblist(7:9,i);
        gaxes = cross(gfront,gup);
        gaxes = gaxes/norm(gaxes,2);
        sizes = rdata.obblist(10:12,i);
        
        ind = strmatch(rdata.id_list{i},model_id,'exact');
        lfront = str2num(model_front{ind});
        lup = [0;1;0];
        laxes = cross(lfront,lup);
        laxes = laxes/norm(laxes,2);
        
        % adjust the sizes
        mid = (max(v)+min(v))/2;
        v = v-repmat(mid,size(v,1),1);
        v = v/sizescale;
        
        %%%%just changed
        modelsize = max(v)-min(v);
        sizes = [sizes(3);sizes(2);sizes(1)];
        sizescale1 = sizes'./modelsize;
        v = v.*repmat(sizescale1,size(v,1),1);
        
        % transform matrix
        translation = cent - min(v);
        transform = [lfront(:)';lup(:)';laxes(:)'];
        transform = [gfront,gup,gaxes]*transform;
        transform = [transform, cent];
        transform = [transform;0,0,0,1];
        vers = [v,ones(size(v,1),1)];
        nvers = transform*vers';
        vn=vn';

        % check texture file
        %texture_filename = [obj_file_path(1:end-4),'.mtl'];
        %texture_des_filename = [output_folder,filesep,'obj-',num2str(i),'.mtl'];
        %suc = copyfile(texture_filename,texture_des_filename);
        %if(suc)
        %    texture_line = ['mtllib ','obj-',num2str(i),'.mtl'];
        %else
        %    texture_line = '';
        %end
        
        % write the obj files
        fid = fopen([output_folder,filesep,'obj-',num2str(i),'.obj'],'w');
        %fprintf(fid,texture_line);
        fprintf(fid,'\n');
        for j = 1:size(nvers,2)
            fprintf(fid, 'v  %f  %f  %f \n', nvers(3,j), nvers(1,j), nvers(2,j));
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
        
    else
        % for walls and floors, output the box
        obb = rdata.obblist(:,i);
        output_filename = [output_folder,filesep,'box-',num2str(i),'.obj'];
        genBox(obb,output_filename);
    end
    
end


end

