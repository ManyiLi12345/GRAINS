function [ clusters ] = objclustering( obblist, Dmat, wallidx, objidx )
%OBJCLUSTERING cluster the objects based on the four walls

sizevec = obblist(10:12,objidx);
sizevec = sizevec.*sizevec;
sizevec = sizevec(1,:)+sizevec(2,:)+sizevec(3,:);
[~,list] = sort(sizevec,'descend');
list = objidx(list);
% distlist = Dmat(objidx,wallidx);
% distlist = min(distlist');
% [~,list] = sort(distlist,'ascend');
% list = objidx(list);


%% first compute the closest wall and distance for each obj
% the orientation(axes) for each floor
wallfront = obblist([4,6],wallidx);
wallaxes = [-wallfront(2,:);wallfront(1,:)];

eps = 0.2;
objlist = zeros(2,length(list)); % first is the closest wall, second is the dist
for i = 1:length(list)
    id = list(i);
    distlist = Dmat(id,wallidx);
    ind = find(abs(distlist)<eps);
    if(length(ind)>1)
        cornerpoints = OBBrep2cornerpoints(obblist(:,id));
        cornerpoints = [max(cornerpoints(:,1))-min(cornerpoints(:,1)),max(cornerpoints(:,3))-min(cornerpoints(:,3))];
        len = abs(cornerpoints*wallaxes(:,ind));
        [~,I] = max(len);
        objlist(:,i) = [ind(I);distlist(ind(I))];
%         oneind = find(ind==1);
%         hasone = length(oneind)>0;
%         hasfour = length(find(ind==4))>0;
%         if(hasone&hasfour)
%             ind(oneind)=5;
%         end
%         ind = min(ind);
%         objlist(:,i) = [ind;distlist(ind)];
    else
        [mdist,I] = min(distlist);
        objlist(:,i) = [I;mdist];
    end
end

clusters = cell(length(wallidx),1);

for i = 1:length(list)
    id = list(i);
    distlist = zeros(length(clusters),1)+100;
    for j = 1:length(clusters)
        clu = clusters{j};
        if(length(clu)>0)
            dlist = Dmat(id,clu);
            distlist(j) = min(dlist);
        end
    end
    wmd = objlist(2,i);
    wid = objlist(1,i);
    if(distlist(wid)>wmd)
        distlist(wid)=wmd;
    end
    [~,I] = min(distlist);
    clusters{I} = [clusters{I};id];
end

%% remove the wall ids from the clusters
for i = 1:length(clusters)
    clusters{i} = setdiff(clusters{i},wallidx);
end

end

