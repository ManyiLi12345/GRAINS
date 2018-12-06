function readMetafiles(labelset_filename, outputfilename, objpath)
%READMETAFILES read the metafiles and collect the model_id, sizes for each
%category

[model_category_title, model_category_body ] = read_csv('v1_ModelCategoryMapping_new_1_babybeds2plants.csv');
index = model_category_body(:,1);
model_id = model_category_body(:,2);
coarse_grained_class = model_category_body(:,9);

load(labelset_filename);
modelid_per_label = cell(1,length(labelset));
for i = 1:length(labelset)
    label = labelset{i};
    ind = strmatch(label, coarse_grained_class, 'exact');
    list = {};
    for j = 1:length(ind)
        mid = model_id{ind(j)};
        list{length(list)+1} = mid;
    end
    modelid_per_label{i} = list;
end

[model_category_title, model_category_body ] = read_csv('models.csv');
objset_per_label = cell(1,length(labelset));
id = model_category_body(:,1);
minPoint = model_category_body(:,4);
maxPoint = model_category_body(:,5);
for i = 1:length(modelid_per_label)
    idlist = modelid_per_label{i};
    objidlist = {};
    objsize = [];
    for j = 1:length(idlist)
        model_id = idlist{j};
        new_path = fullfile(objpath, model_id);
        obj_file_path = dir(fullfile(new_path,'*.obj'));
        if(length(obj_file_path)>0)
            path = [obj_file_path.folder, filesep, obj_file_path.name]
            obj_file_path = fullfile(obj_file_path.folder, obj_file_path.name);
            [ msize ] = readOBJSize( obj_file_path );
            objidlist{length(objidlist)+1} = model_id;
            objsize(:,size(objsize,2)+1) = msize(:);
        end
    end
    mset.objidlist = objidlist;
    mset.objsize = objsize;
    objset_per_label{i} = mset; 
end

save(outputfilename, 'objset_per_label');

end

