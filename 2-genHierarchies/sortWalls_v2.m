function [ data ] = sortWalls_v2( data )
%SORTWALLS_V2 set the obb of four walls and the floor
[ data ] = sortWalls( data );

wallind = strmatch('wall',data.labellist,'exact');
objidx = setdiff(1:size(data.obblist,2),wallind);

% compute the bounding box of all objects
pobb = data.obblist(:,objidx(1));
for i = 2:length(objidx)
    obb2 = data.obblist(:,objidx(i));
    pobb = updateOBB([pobb,obb2],[1,2]);
end

% modify the floor
originalwallwidth = data.obblist(10,wallind(1));
wallwidth = 0.02;%0.011
floorheight = 0.1;
floorid = strmatch('floor',data.labellist,'exact');
floorobb = data.obblist(:,floorid);
% floorobb(10:12) = pobb(10:12);
floorobb(10) = floorobb(10)+(wallwidth-originalwallwidth)*2;
floorobb(12) = floorobb(12)+(wallwidth-originalwallwidth)*2;
floorobb(11) = floorheight;
data.obblist(:,floorid) = floorobb;

% create the walls
roomheight = pobb(11);
rcent = floorobb(1:3);
rfront = floorobb(4:6);
rup = floorobb(7:9);
rcent = rcent + rup*(floorheight/2+roomheight/2) ;
raxes = cross(rfront,rup);
raxes = raxes/norm(raxes,2);
rwidth = floorobb(12);
rheight = floorobb(10);

walllabel = data.obblist(13:end,wallind(1));

% wall1
wcent = rcent - rfront*(rheight/2-wallwidth/2);
wfront = rfront;
wup = rup;
wsize = [wallwidth;roomheight;rwidth-2*wallwidth];
wall1 = [wcent;wfront;wup;wsize;walllabel];
distlist = zeros(size(data.Dmat,1),1);
for i = 1:length(objidx)
    distlist(i) = obbdist(data.obblist(:,objidx(i))',wall1');
end
data.Dmat(:,wallind(1)) = distlist;
data.Dmat(wallind(1),:) = distlist';

% wall2 
wcent = rcent + raxes*(rwidth/2-wallwidth/2);
wfront = -raxes;
wup = rup;
wsize = [wallwidth;roomheight;rheight-2*wallwidth];
wall2 = [wcent;wfront;wup;wsize;walllabel];
distlist = zeros(size(data.Dmat,1),1);
for i = 1:length(objidx)
    distlist(i) = obbdist(data.obblist(:,objidx(i))',wall2');
end
data.Dmat(:,wallind(2)) = distlist;
data.Dmat(wallind(2),:) = distlist';

% wall3 
wcent = rcent + rfront*(rheight/2-wallwidth/2);
wfront = -rfront;
wup = rup;
wsize = [wallwidth;roomheight;rwidth-2*wallwidth];
wall3 = [wcent;wfront;wup;wsize;walllabel];
distlist = zeros(size(data.Dmat,1),1);
for i = 1:length(objidx)
    distlist(i) = obbdist(data.obblist(:,objidx(i))',wall3');
end
data.Dmat(:,wallind(3)) = distlist;
data.Dmat(wallind(3),:) = distlist';

% wall4
wcent = rcent - raxes*(rwidth/2-wallwidth/2);
wfront = raxes;
wup = rup;
wsize = [wallwidth;roomheight;rheight-2*wallwidth];
wall4 = [wcent;wfront;wup;wsize;walllabel];
distlist = zeros(size(data.Dmat,1),1);
for i = 1:length(objidx)
    distlist(i) = obbdist(data.obblist(:,objidx(i))',wall4');
end
data.Dmat(:,wallind(4)) = distlist;
data.Dmat(wallind(4),:) = distlist';

data.obblist(:,wallind) = [wall1,wall2,wall3,wall4];
data.Dmat(wallind(1),wallind(3)) = rheight-2*wallwidth;
data.Dmat(wallind(3),wallind(1)) = rheight-2*wallwidth;
data.Dmat(wallind(2),wallind(4)) = rwidth-2*wallwidth;
data.Dmat(wallind(4),wallind(2)) = rwidth-2*wallwidth;

%% remove the surround relation involving the floor and wall
boxidx = [wallind(:);floorid];
nsur = {};
for i = 1:length(data.sur)
    list = data.sur{i};
    ind = intersect(list,boxidx);
    if(length(ind)==0)
        nsur{length(nsur)+1} = list;
    end
end
data.sur = nsur;

Rmat = data.Rmat;
ind = find(Rmat(floorid,:)==-3);
Rmat(floorid,ind) = -1;
Rmat(ind,floorid) = -2;
Rmat(floorid, wallind) = -1;
Rmat(wallind, floorid) = -2;
data.Rmat = Rmat;

end

