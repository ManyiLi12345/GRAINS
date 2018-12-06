function [ rdata ] = reconOffset2Scene( ndata, sizescale, maxlayer, index, labelset_filename, objperlabel_filename, objpath )
%RECONOFFSET2SCENE reconstruct the offset format into scenes

addpath(genpath('..\3-datapreparation'));
addpath(genpath('..\vistools'));

load(labelset_filename);

if(exist(objperlabel_filename))
    load(objperlabel_filename);
else
    readMetafiles(labelset_filename, objperlabel_filename, objpath);
    load(objperlabel_filename);
end

categorynum = length(labelset)-2;

% adjust the obj sizes
nsizevec = zeros(3,size(ndata.leafreps,2)); % the 3d sizes of real vectors
id_list = cell(1,size(ndata.leafreps,2));
for i = 1:size(ndata.leafreps,2)
    reconsize = ndata.leafreps(1:3,i);
    reconlabel = ndata.leafreps(4:end,i);
    [~,I] = max(reconlabel);
    reconlabel = zeros(size(reconlabel));
    reconlabel(I) = 1;
    objset = objset_per_label{I};
    
    if(I<categorynum+1)
        objsize = objset.objsize;
        objidlist = objset.objidlist;
        sizelist = objsize([3,2,1],:)/sizescale;
        lenlist = sizelist - repmat(reconsize(:),1,size(sizelist,2));
        lenlist = lenlist.^2;
        lenlist = lenlist(1,:)+lenlist(2,:)+lenlist(3,:);
    
        [~,I] = min(lenlist);
        id = objidlist{I};
        id_list{i} = id;
        nsizevec(:,i) = objsize([3,2,1],I)/sizescale;
        ndata.leafreps(:,i) = [sizelist(:,I);reconlabel];
    else
        ndata.leafreps(4:end,i) = [reconlabel];
        if(I==categorynum+2)
            ndata.leafreps(1,i) = 0.02;
            nsizevec(1,i) = 0.02;
            nsizevec(2,i) = 0.4;
        else
            nsizevec(2,i) = 0.02;
        end
    end
end

% reconstruct the layout
[rdata] = readOffsetRep_v2( ndata, labelset, 1 , index);
rdata.id_list = id_list;
rdata.obblist(11,:) = nsizevec(2,:);

end

