% pre-process the dataset

%% 1. scale all data into [-1,1] (actually the room are scaled into [-0.5,0.5], because the room size is [-1,1])
maxscale = 0;
maxlayer = 0;
for i = 1:length(dataset)
    data = dataset{i};
    obblist = data.obblist;
    m = max(abs(obblist(:)));
    maxscale = max([maxscale, m]);
end

for i = 1:length(dataset)
    data = dataset{i};
    obblist = data.obblist;
    obblist(1:3,:) = obblist(1:3,:)/maxscale;
    obblist(10:12,:) = obblist(10:12,:)/maxscale;
    data.obblist = obblist;
      
    dataset{i} = data;
end