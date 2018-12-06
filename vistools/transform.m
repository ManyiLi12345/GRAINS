ndataset = {};
location = ['rooms',filesep];
for i = 1:length(dataset)
    data = dataset{i};
    obblist = data.obblist;
    nobblist = [];
    for j = 1:size(obblist,2)
        obb = obblist(1:12,j);
        label = obblist(13:end,j);
        label = binary2dec(label);
        cornerpoints = OBBrep2cornerpoints(obb);
        nobb = [label];
        for k = 1:size(cornerpoints,1)
            nobb = [nobb;cornerpoints(k,:)'];
        end
        nobblist = [nobblist,nobb];
    end
    ndataset{i} = nobblist;
    
    filename = [location, num2str(i),'.txt'];
    fid = fopen(filename,'w');
    for j = 1:size(nobblist,2)
        nobb = nobblist(:,j);
        for k = 1:length(nobb)
            fprintf(fid, '%f ', nobb(k));
        end
        fprintf(fid,'\n');
    end
    fclose(fid);
end