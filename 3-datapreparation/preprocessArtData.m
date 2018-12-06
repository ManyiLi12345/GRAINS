labelset = {'bed','stand','lamp','rug','ottoman','person','floor'};
for i = 1:length(dataset)
    data = dataset{i};
    
    data.obblist = data.leafreps(1:12,:);
    layers = ones(size(data.leafreps,2),1);
    labellist = {};
    for j = 1:size(data.leafreps,2)
        label = data.leafreps(13:end,j);
        [~,I] = max(label);
        label = labelset{I};
        if(I==3|I==6)
            layers(j) = 2;
        end
        labellist{j} = label;
    end
    data.labellist = labellist;
    data.layers = layers;
%     plotRoom2(data.obblist,data.labellist,0);
    dataset{i} = data;
end

preprocess;