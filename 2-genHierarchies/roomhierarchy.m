function [ kids, ntypelist, layers ] = roomhierarchy( data, RELATIONS, NODETYPES )
%ROOMHIERARCHY 

obblist = data.obblist;
Rmat = data.Rmat;
Dmat = data.Dmat;
labellist = data.labellist;
sur = data.sur;
objnum = size(obblist,2);

%% build support tree
supportparent = zeros(size(obblist,2),1);
for i = 1:objnum
    rlist = Rmat(:,i);
    pp = find(rlist==RELATIONS.SUPPORT1);
    if(length(pp)>1)
        pd = Dmat(i,pp);
        [~,I] = min(pd);
        supportparent(i) = pp(I);
    end
    if(length(pp)==1)
        supportparent(i) = pp;
    end
end

%% compute the layer values
% nobjlist = length(supportparent);% add the floor
% layers = zeros(size(obblist,2),1);
% layers(nobjlist(1)) = 1;
% while(length(nobjlist)>0)
%     i = nobjlist(1);
%     nobjlist = nobjlist(2:end);
%     ind = find(supportparent==i);
%     nobjlist = [nobjlist;ind];
%     layers(ind) = layers(i)+1;
% end

%% split by surround relation
parent = [supportparent(:)';zeros(1,length(supportparent))+NODETYPES.SUPPORT];
flooridx = strmatch('floor',labellist,'exact');
parent(1,flooridx) = 0;
% a central object may be involved with multiple surround relations,
% but it can have only one parent
for i = 1:objnum
    % find the possible parents, sur pair id, distance in the relation
    pdlist = [];
    for j = 1:length(sur)
        slist = sur{j};
        if(slist(1)==i&&length(slist)>2)
            t = tabulate(supportparent(slist(2:end)));
            if(size(t,2)>1)
                [~,pp] = max(t(:,2));
            else
                pp = 1;
            end
            pd = [t(pp,1),j,Dmat(slist(1),slist(2))];
            pdlist = [pdlist;pd];
        end
    end
    surind = [];
    if(size(pdlist,1)>0)
        ind = find(pdlist(:,1)==parent(1,i));
        surind = pdlist(ind,2);
    end
    
    if(length(surind)>1)
        slist = sur{surind(1)};
        surchildlist = slist(2:end);
        innodelist = [];
        for j = 1:length(surchildlist)
            plist = [surchildlist(j)];
            for k = 2:length(surind)
                sklist = sur{surind(k)};
                sklist = sklist(2:end);
                dlist = Dmat(surchildlist(j),sklist);
                [~,I] = min(dlist);
                plist = [plist,sklist(I)];
            end
            parent(:,size(parent,2)+1) = [0;NODETYPES.COOCCUR]; % note here may make mistake
            parent(1,plist) = size(parent,2);
            obblist(:,size(obblist,2)+1) = updateOBB(obblist,plist);
            innodelist = [innodelist;size(parent,2)];
        end
%         parent(innodelist) = i;% assign the central obj as their parent
        innodelist = [i;innodelist(:)];
        parent(:,size(parent,2)+1) = [parent(1,i);NODETYPES.SURROUND];
        parent(1,innodelist) = size(parent,2); % assign the central obj as their parent
        obblist(:,size(obblist,2)+1) = updateOBB(obblist,innodelist);
    end
    
    if(length(surind)==1)
        slist = sur{surind(1)};
        parent(:,size(parent,2)+1) = [parent(1,i);NODETYPES.SURROUND];
        parent(1,slist) = size(parent,2);
        obblist(:,size(obblist,2)+1) = updateOBB(obblist,slist);
    end
end

%% create the distmat for all the current nodes
distmat = Dmat;
for i = 1+objnum:size(parent,2)
    ind = find(parent(1,:)==i);
    dm = distmat(ind,:);
    if(length(ind)>1)
        dm = min(dm);
    end
    if(length(ind)>0)
        distmat = [distmat; dm];
        dm = [dm(:);0];
        distmat = [distmat,dm];
    end
end

wallidx = strmatch('wall',labellist,'exact');
flooridx = strmatch('floor',labellist,'exact');
if(length(wallidx)>0)
    %% create wall nodes
    %% shoud be changed to obj cluster algorithm
    floorchildlist = find(parent(1,:)==flooridx);
    floorchildlist = setdiff(floorchildlist,wallidx);
    [ clusters ] = objclustering( obblist, distmat, wallidx, floorchildlist );
     for j = 1:length(clusters)
        list = clusters{j};
        parent(1,list) = wallidx(j);
    end
%     for i = 1:length(floorchildlist)
%         cid = floorchildlist(i);
%         distlist = distmat(cid,wallidx);
%         [~,I] = min(distlist);
%         parent(:,cid) = [wallidx(I);parent(2,cid)];
%     end
%     
end
parent(2,wallidx) = NODETYPES.WALL;
parent(2,flooridx) = NODETYPES.ROOM;%%%%%%%%%

% colorlist = {'r','g','b','k'};
% for i = 1:length(clusters)
%     c = clusters{i};
%     draw3dOBB_v2(obblist(:,wallidx(i)),colorlist{i});
%     for j = 1:length(c)
%         draw3dOBB_v2(obblist(:,c(j)),colorlist{i});
%     end
% end

[ kids, ntypelist ] = organize_binarytree( parent, distmat, objnum, NODETYPES, flooridx);

%% check and correct the ntypelist
for i = 1:length(ntypelist)
    flag = ntypelist(i);
    if(flag==NODETYPES.COOCCUR)
        k = kids{i};
        if(k(1)<size(Rmat,1)&k(2)<size(Rmat,1))
            rel = Rmat(k(1),k(2));
            if(rel==RELATIONS.SUPPORT1)
                ntypelist(i) = NODETYPES.SUPPORT;
            end
            if(rel==RELATIONS.SUPPORT2)
                ntypelist(i) = NODETYPES.SUPPORT;
                tmp = k(1);
                k(1) = k(2);
                k(2) = tmp;
            end
            kids{i} = k;
        end
    end
end

end