ndataset = {};
for i = 1:length(dataset)
    data = dataset{i};
    floorobb = data.obblist(:,size(data.obblist,2));
    fsize1 = floorobb(10);
    fsize2 = floorobb(12);
    if(abs(fsize1-fsize2)<0.1)
        ndataset{length(ndataset)+1} = data;
    end
end