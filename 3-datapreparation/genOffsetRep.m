function [ ndata ] = genOffsetRep( data, labelset )
%GENOFFSETREP transform the data into offset format.
% INPUT: data - the data is a struct with 
%                   "kids" (hierarchy) and 
%                   "obblist" (boxes with absolute positions)
%                   "labellist" (labels of the boxes)
%                   "layers" (layers of the boxes)
%        labelset - the category list for this dataset
%
% OUTPUT: ndata - the ndata is a struct with 
%                   "kids" (hierarchy) the same with input
%                   "leafreps" (layer+label of boxes)
%                   "relposreps" (relative positions between siblings)

%addpath(genpath('..\0-data'));
addpath(genpath('..\vistools'));

kids = data.kids;
obblist = data.obblist;
labellist = data.labellist;
leafnum = size(obblist,2);
nodenum = length(kids);

%% extract the sizes
sizevec = obblist([10:12],:);

%% extract the layers
% if(isfield(data,'layers'))
%     layers = data.layers;
% end

%% extract the labels
classnum = length(labelset);
labelvecs = zeros(classnum, length(labellist));
for i = 1:leafnum
    label = labellist{i};
    ind = strmatch(label,labelset,'exact');
    labelvecs(ind,i) = 1;
end

%% compute the relative positions
% 1. update the boxes of the internal nodes
obblist = obblist(1:12,:);
for j = leafnum+1:nodenum
	k = kids{j};
    flag = k(1);
    switch(flag)
        case 1
            % support
            obb1 = obblist(:,k(2));
            obb2 = obblist(:,k(3));
            pobb = updateOBB_v2(obb1, obb2);
            obblist(:,j) = pobb;
        case 2
            % group
            obb1 = obblist(:,k(2));
            obb2 = obblist(:,k(3));
            len1 = norm(obb1(10:12),2);
            len2 = norm(obb2(10:12),2);
            if(len1>len2)
            	pobb = updateOBB_v2(obb1,obb2);
            else
            	pobb = updateOBB_v2(obb2,obb1);
            	tmp = k(3);
                k(3) = k(2);
                k(2) = tmp;
            end
            obblist(:,j) = pobb;
        case 3
            % surround
            obb1 = obblist(:,k(2));
            obb2 = obblist(:,k(3));
            obb3 = obblist(:,k(4));
            cent1 = obb1(1:3);
            front1 = obb1(4:6);
            up1 = obb1(7:9);
            cent2 = obb2(1:3);
            front2 = cent2 - cent1;
            cent3 = obb3(1:3);
            front3 = cent3 - cent1;
            transform = genTransMat(front1,up1);
            front2 = transform*front2;
            front2 = front2/norm(front2);
            degree2 = atand(front2(3)/front2(1));
            if(front2(1)<0)
                if(degree2<0)
                    degree2 = degree2-180;
                else
                    degree2 = degree2+180;
                end
            end
            degree2 = mod(degree2,360);
            front3 = transform*front3;
            front3 = front3/norm(front3);
            degree3 = atand(front3(3)/front3(1));
            if(front3(1)<0)
                if(degree3<0)
                    degree3 = degree3-180;
                else
                    degree3 = degree3+180;
                end
            end
            degree3 = mod(degree3,360);
            if(degree3<degree2)
                tmp = obb2;
                obb2 = obb3;
                obb3 = tmp;
                tmp = k(3);
                k(3) = k(4);
                k(4) = tmp;
            end
            pobb = updateOBB_v2(obb1, obb2);
            pobb = updateOBB_v2(pobb, obb3);
            obblist(:,j) = pobb;
        case 4
            % room
            obb1 = obblist(:,k(2));
            obb2 = obblist(:,k(3));
            pobb = updateOBB_v2(obb1, obb2);
            obb2 = obblist(:,k(4));
            pobb = updateOBB_v2(pobb, obb2);
            obb2 = obblist(:,k(5));
            pobb = updateOBB_v2(pobb, obb2);
            obb2 = obblist(:,k(6));
            pobb = updateOBB_v2(pobb, obb2);
            obblist(:,j) = pobb;
        case 5
            % wall
            obb1 = obblist(:,k(2));
            obb2 = obblist(:,k(3));
            pobb = updateOBB_v2(obb1, obb2);
            obblist(:,j) = pobb;
    end
    kids{j} = k;
end

%% splitting walls
% for i = 1:length(kids)
%     k = kids{i};
% 	if(k(1)==5)
%         box1 = obblist(:,k(2));
%         box2 = obblist(:,k(3));
%         [ rp, psize3,delta_midy ] = gen2dOffset_v2( box1, box2, 1 );
%         sizevec(3,k(2)) = psize3;
%         obblist(12,k(2)) = psize3;
%         cent1 = obblist(1:3,k(2));
%         front1 = obblist(4:6,k(2));
%         up1 = obblist(7:9,k(2));
%         axes1 = cross(front1,cent1);
%         axes1 = axes1/norm(axes1,2);
%         cent1 = cent1-axes1*delta_midy;
%         obblist(1:3,k(2)) = cent1;
%         obblist(:,i) = updateOBB_v2(obblist(:,k(2)), obblist(:,k(3)));
%     end
%     if(k(1)==4)
%         obb1 = obblist(:,k(2));
%         obb2 = obblist(:,k(3));
%         pobb = updateOBB_v2(obb1, obb2);
%         obb2 = obblist(:,k(4));
%         pobb = updateOBB_v2(pobb, obb2);
%         obb2 = obblist(:,k(5));
%         pobb = updateOBB_v2(pobb, obb2);
%         obb2 = obblist(:,k(6));
%         pobb = updateOBB_v2(pobb, obb2);
%         obblist(:,i) = pobb;
%     end
% end

% 2. compute the relative positions between childen and parents
relposreps = {};
for i = 1:leafnum
    relposreps{i} = [];
end
for i = leafnum+1:nodenum
%     pobb = obblist(:,i);
    k = kids{i};
    rplist = [];
    if(length(k)>2)
        box1 = obblist(:,k(2));
        for j = 3:length(k)
            box2 = obblist(:,k(j));
            
            % compute the relative positions between two boxes
            [ rp ] = gen2dOffset_v2( box1, box2, 0 );
            rplist = [rplist, rp];
        end
    end
    relposreps{i} = rplist;
end

lastmerge = kids{length(kids)};
wallidx = lastmerge(3:end);
rplist = [];
box1 = obblist(:,lastmerge(2));
for i = 1:length(wallidx)
    box2 = obblist(:,wallidx(i));
    rp = gen2dOffset_v2(box1, box2, 0);
    rplist = [rplist, rp];
    box1 = box2;
end
relposreps{length(relposreps)} = rplist;

% colorlist = {'r','y','g','b'};
% for i = 1:length(wallidx)
%     if(wallidx(i)>leafnum)
%         k = kids{wallidx(i)};
%         draw3dOBB_v2(obblist(:,k(2)),colorlist{i});
%         draw3dOBB_v2(obblist(:,k(3)),colorlist{i});
%     else
%         draw3dOBB_v2(obblist(:,wallidx(i)),colorlist{i});
%     end
% end
% close gcf

%% 3. compute the attachment to the walls
% wallattachment = [];
% for i = 1:size(obblist,2)
%     obb = obblist(:,i);
%     wallattach = zeros(size(data.walllist,2),1);
%     for j = 1:size(data.walllist,2)
%         wobb = data.walllist(:,j);
%         dist = obbdist(obb',wobb');
%         wallattach(j) = dist<0.01;
%     end
%     wallattachment = [wallattachment,wallattach];
% end

%% form the leafreps
leafreps = labelvecs;
% if(exist('layers','var'))
%     leafreps = [layers';leafreps];
% end
leafreps = [sizevec;leafreps];

%% form the ndata
ndata.kids = kids;
ndata.leafreps = leafreps;
ndata.relposreps = relposreps;
% ndata.wallattachment = wallattachment;

end

