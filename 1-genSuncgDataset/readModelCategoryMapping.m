function readModelCategoryMapping( filename )

[model_category_title, model_category_body ] = read_csv(filename);
% title: index, model_id, fine_grained_class, coarse_grained_class,
% empty_struct_obj, nyuv2_40class, wnsynsetid, wnsynsetkey

indexlist = {};
cmlist = {};
for i = 1:size(model_category_body,1)
    index = model_category_body{i,1};
    model_id = model_category_body{i,2};
    fine_grained_class = model_category_body{i,3};
    coarse_grained_class = model_category_body{i,4};
    empty_struct_obj = model_category_body{i,5};
    nyuv2_40class = model_category_body{i,6};
    wnsynsetid = model_category_body{i,7};
    wnsynsetkey = model_category_body{i,8};
    grains_class = model_category_body{i,9};

    cm.index = index;
    cm.model_id = model_id;
    cm.fine_grained_class = fine_grained_class;
    cm.coarse_grained_class = coarse_grained_class;
    cm.empty_struct_obj = empty_struct_obj;
    cm.nyuv2_40class = nyuv2_40class;
    cm.wnsynsetid = wnsynsetid;
    cm.wnsynsetkey = wnsynsetkey;
    cm.grains_class = grains_class;

    cmlist{i} = cm;
    indexlist{i} = index;
end

ModelCategoryMapping = containers.Map(indexlist, cmlist);
save(['..',filesep,'0-data',filesep,'ModelCategoryMapping.mat'],'ModelCategoryMapping');

end

