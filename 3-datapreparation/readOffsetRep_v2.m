function [ data, rootsize ] = readOffsetRep_v2( ndata, labelset, opti, aaaindex )
%READOFFSETREP_V2 read the offset representations and  recover the boxes with absolute positions
% reconstruct the absolute positions by forward propagation
%
% INPUT: ndata - the ndata is a struct with 
%                 "kids" (hierarchy)
%                 "leafreps" (layer+label of boxes)
%                 "relposreps" (relative positions between siblings)
%        labelset - the category list for this dataset
%        opti - whether to optimize the support relation
%
% OUTPUT: data - the data is a struct with
%                 "kids" (hierarchy) the same with input
%                 "obblist" (boxes with absolute positions)
%                 "labellist" (labels of the boxes)
%                 "layers" (layers of the boxes)

kids = ndata.kids;
leafreps = ndata.leafreps;
relposreps = ndata.relposreps;
leafnum = size(leafreps,2);
nodenum = length(kids);

%% extract the labels%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% labellist = {};
classnum = length(labelset);
labelvec = leafreps(end-classnum+1:end,:);
labellist = {};
for i = 1:leafnum
    label = labelvec(:,i);
    [~,I] = max(label);
    label = labelset{I};
    labellist{i} = label;
end

% %% extract the layers
% if(size(leafreps,1)-classnum>0)
%     layers = leafreps(3,:);
% end

%% update the sizes of all nodes
sizevec = leafreps(1:3,:);
for i = 1:nodenum
    k = kids{i};
    rplist = relposreps{i};
    if(length(k)>2)
        size1 = sizevec([1,3],k(2));
        pmaxx = size1(1)/2;
        pmaxy = 0;
        pmaxz = size1(2)/2;
        pminx = -size1(1)/2;
        pmaxy = 0;
        pminz = -size1(2)/2;
        for j = 3:length(k)
            rp = rplist(:,j-2);
            size2 = sizevec([1,3],k(j));
            [ maxx, maxz, minx, minz ] = genCorFrom2dOffset_v2( rp, size1, size2 );
            pmaxx = max(pmaxx,maxx);
            pmaxz = max(pmaxz,maxz);
            pminx = min(pminx,minx);
            pminz = min(pminz,minz);
        end
        pmidx = (pmaxx+pminx)/2;
        pmidz = (pmaxz+pminz)/2;
        psizex = (pmaxx-pminx);
        psizez = (pmaxz-pminz);
        pobb = [0;0;0;1;0;0;0;1;0;psizex;0;psizez];
        cmaxx = size1(1)/2;
        cminx = -size1(1)/2;
        cmaxz = size1(2)/2;
        cminz = -size1(2)/2;
        cmidx = (cmaxx+cminx)/2;
        cmidz = (cmaxz+cminz)/2;
        cobb = [cmidx-pmidx;0;cmidz-pmidz;1;0;0;0;1;0;size1(1);0;size1(2)];
        rp = gen2dOffset_v2( pobb, cobb, 0 );
        rplist = [rp,rplist];
        sizevec(:,i) = [psizex;0;psizez]; % the sizes under its own local frame
    end
    relposreps{i} = rplist;
end

%% size of the room
k = kids{length(kids)};
rplist = relposreps{length(relposreps)};
rplist = rplist(:,2:end);
size1 = sizevec([1,3],k(2));
cent1 = [0;0;0];
front1 = [1;0;0];
up1 = [0;1;0];
pmaxx = size1(1)/2;
pmaxy = 0;
pmaxz = size1(2)/2;
pminx = -size1(1)/2;
pmaxy = 0;
pminz = -size1(2)/2;
box1 = [cent1;front1;up1;(pmaxx-pminx);0;(pmaxz-pminz)];
obbset = [];
for j = 3:length(k)
	rp = rplist(:,j-2);
    size2 = sizevec([1,3],k(j));
	[ ~,~,~,~, nfront, maxx, maxz, minx, minz ] = genCorFrom2dOffset_v2( rp, size1, size2 );
    axes1 = cross(front1,up1);
    axes1 = axes1/norm(axes1,2);
    
%     tsize = [(maxx-minx);0;(maxz-minz)];
%     tsize = tsize(1)*[1;0;0]+tsize(3)*[0;0;1];
%     tsize = [tsize(1)*[1;0;0]*nfront;0;tsize'*axes1];
    
    transform = [front1(:)';up1(:)';axes1(:)'];
    nfront = inv(transform)*nfront;
    naxes = cross(nfront,up1);
    naxes = naxes/norm(naxes,2);
	
    pcent = cent1;
    cent1 = [(maxx+minx)/2;0;(maxz+minz)/2];
    cent1 = inv(transform)*cent1+pcent;
    front1 = nfront(:);
    size1 = size2;
    cobb = [cent1;front1;up1;sizevec(:,k(j))];
    obbset = [obbset, cobb];
end
pobb = box1;
for j = 1:size(obbset,2)
    pobb = updateOBB_v2(pobb,obbset(:,j));
end
rp = gen2dOffset_v2( pobb, box1, 0 );
sizevec(:,length(kids)) = pobb(10:12);
rplist = [rp,rplist];
relposreps{length(relposreps)} = rplist;

%% compute the absolute positions of the boxes
obblist = zeros(12,nodenum);
obblist(:,end) = [0;0;0;1;0;0;0;1;0;1;0;1];
rootsize = sizevec(:,end);
obblist(10,end) = rootsize(1);
obblist(12,end) = rootsize(3);
%% set floor size
k = kids{length(kids)};
floorid = k(2);
sizevec(:,floorid) = rootsize;

%% recon last merge
% index = nodenum;
% pobb = obblist(:,index);
% k = kids{index};
% rplist = relposreps{index};
% rp = rplist(:,1);
% rp = [rp(1);sizevec([1,3],k(2));rp(2:end)];
% cobb = genOBBfrom2dOffset_v2( pobb, rp );
% obblist(:,k(2)) = cobb;
% pobb = cobb;
% for j = 3:length(k)
% 	rp = rplist(:,j-1);
% 	rp = [rp(1);sizevec([1,3],k(j));rp(2:end)];
% 	cobb = genOBBfrom2dOffset_v2( pobb, rp );
% 	if(opti&k(1)==1)
%         % optimize the support relation
%         % move the cobb in the center of pobb
%         cobb([1,3]) = pobb([1,3]);
%     end
% 	obblist(:,k(j)) = cobb;
%     pobb = cobb;
% end

% draw3dOBB_v2(box1,'k');
% draw3dOBB_v2(obbset(:,1),'r');
% draw3dOBB_v2(obbset(:,2),'y');
% draw3dOBB_v2(obbset(:,3),'g');
% draw3dOBB_v2(obbset(:,4),'b');
% saveas(gcf, ['images',filesep,num2str(aaaindex),'-lastmerge-before_adjustment.jpg']);
% close gcf

rplist = [];
for i = 1:size(obbset,2)
    box2 = obbset(:,i);
    rp = gen2dOffset_v2( pobb, box2, 0 );
    rplist = [rplist,rp];
end
% rp1
rp = rplist(:,1);
[ rp ] = adjustRelposBetweenWallFloor( rp, 0, 2, 1 ); % x axis
rplist(:,1) = rp;
% rp1
rp = rplist(:,2);
[ rp ] = adjustRelposBetweenWallFloor( rp, 1, 3, 1 ); % y axis
rplist(:,2) = rp;
% rp1
rp = rplist(:,3);
[ rp ] = adjustRelposBetweenWallFloor( rp, 0, 3, 1 ); % x axis
rplist(:,3) = rp;
% rp1
rp = rplist(:,4);
[ rp ] = adjustRelposBetweenWallFloor( rp, 1, 2, 1 ); % y axis
rplist(:,4) = rp;
rplist1 = relposreps{length(relposreps)};
rplist = [rplist1(:,1),rplist];
relposreps{length(relposreps)} = rplist;
    
for i = nodenum:-1:1
    pobb = obblist(:,i);
    k = kids{i};
    rplist = relposreps{i};
    if(length(k)>1)
        rp = rplist(:,1);
        rp = [rp(1);sizevec([1,3],k(2));rp(2:end)];
        cobb = genOBBfrom2dOffset_v2( pobb, rp );
        obblist(:,k(2)) = cobb;
        pobb = cobb;
        for j = 3:length(k)
            rp = rplist(:,j-1);
            rp = [rp(1);sizevec([1,3],k(j));rp(2:end)];
            cobb = genOBBfrom2dOffset_v2( pobb, rp );
            if(opti&k(1)==1)
                % optimize the support relation
                % move the cobb in the center of pobb1
                cobb([1,3]) = pobb([1,3]);
            end
            obblist(:,k(j)) = cobb;
        end
    else
        % object
    end
end

% lastmerge = kids{length(kids)};
% k = lastmerge(3:end);
% draw3dOBB_v2(obblist(:,lastmerge(2)),'k');
% draw3dOBB_v2(obblist(:,k(1)),'r');
% draw3dOBB_v2(obblist(:,k(2)),'y');
% draw3dOBB_v2(obblist(:,k(3)),'g');
% draw3dOBB_v2(obblist(:,k(4)),'b');
% saveas(gcf, ['images',filesep,num2str(aaaindex),'-lastmerge_after_adjustment.jpg']);
% close gcf;

% form the data
data.kids = kids;
data.labellist = labellist;
data.obblist = obblist(:,1:leafnum);
data.obblist([10:12],:) = leafreps(1:3,:);

%% set the floor size
k = kids{length(kids)};
floorid = k(2);
data.obblist([10:12],floorid) = rootsize;

%% set wall obb
k = kids{length(kids)};
wallind = k(3:end);
for i = 1:length(wallind)
    id = wallind(i);
    while(length(kids{id})>1)
        tmp = kids{id};
        id = tmp(2);
    end
    wallind(i) = id;
end
wallwidth = sizevec(1,wallind(1));
fobb = data.obblist(:,floorid);
fcent = fobb(1:3);
ffront = fobb(4:6);
fup = fobb(7:9);
faxes = cross(ffront,fup);
faxes = faxes/norm(faxes,2);
fwidth = fobb(12);
fheight = fobb(10);

% wall1
wcent = fcent - ffront*(fheight/2-wallwidth/2);
wfront = ffront;
wup = fup;
wsize = [wallwidth;sizevec(2,wallind(1));rootsize(3)];
data.obblist(:,wallind(1)) = [wcent;wfront;wup;wsize];

% wall2 
wcent = fcent + faxes*(fwidth/2-wallwidth/2);
wfront = -faxes;
wup = fup;
wsize = [wallwidth;sizevec(2,wallind(1));rootsize(1)];
data.obblist(:,wallind(2)) = [wcent;wfront;wup;wsize];

% wall3 
wcent = fcent + ffront*(fheight/2-wallwidth/2);
wfront = -ffront;
wup = fup;
wsize = [wallwidth;sizevec(2,wallind(1));rootsize(3)];
data.obblist(:,wallind(3)) = [wcent;wfront;wup;wsize];

% wall4
wcent = fcent - faxes*(fwidth/2-wallwidth/2);
wfront = faxes;
wup = fup;
wsize = [wallwidth;sizevec(2,wallind(1));rootsize(1)];
data.obblist(:,wallind(4)) = [wcent;wfront;wup;wsize];

% if(exist('layers','var'))
%     data.layers = layers;
% end

end

