function readModelOri( filename )

[model_category_title, model_category_body ] = read_csv(filename);
% title: id, front, nmaterial, minPoint, maxPoint, aligned.dims, index,
% variantIds

idlist = {};
cmlist = {};
for i = 1:size(model_category_body,1)
    id = model_category_body{i,1};
    front = str2num(model_category_body{i,2});
    nmaterial = model_category_body{i,3};
    minPoint = str2num(model_category_body{i,4});
    maxPoint = str2num(model_category_body{i,5});
    aligned_dimes = str2num(model_category_body{i,6});
    index = model_category_body{i,7};
    variantIds = model_category_body{i,8};

    cm.id = id;
    cm.front = front;
    cm.nmaterial = nmaterial;
    cm.minPoint = minPoint;
    cm.maxPoint = maxPoint;
    cm.aligned_dimes = aligned_dimes;
    cm.index = index;
    cm.variantIds = variantIds;

    cmlist{i} = cm;
    idlist{i} = id;
end

Models = containers.Map(idlist, cmlist);
save(['..',filesep,'0-data',filesep,'Models.mat'],'Models');

end

