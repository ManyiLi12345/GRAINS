function [ data ] = readOffsetRep( ndata, labelset )
%READOFFSETREP read the offset representations and  recover the boxes with
%absolute positions
%
% INPUT: ndata - the ndata is a struct with 
%                 "kids" (hierarchy)
%                 "leafreps" (layer+label of boxes)
%                 "relposreps" (relative positions between child
%                 and parent)
%        labelset - the category list for this dataset
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

%% extract the labels
classnum = length(labelset);
labelvec = leafreps(end-classnum+1:end,:);
labellist = {};
for i = 1:leafnum
    label = labelvec(:,i);
    [~,I] = max(label);
    label = labelset{I};
    labellist{i} = label;
end

%% extract the layers
if(size(leafreps,1)-classnum>0)
    layers = leafreps(1,:);
end

%% compute the absolute positions of the boxes
obblist = zeros(12,nodenum);
% obblist(:,end) = [0.0322;0;-0.0885;1;0;0;0;1;0;0.49;0;1.0670]; % the root box
obblist(:,end) = [0;0;0;1;0;0;0;1;0;1;0;1];
% [ psize ] = getRootSize( ndata );
% obblist(10:12,end) = psize;
lastmergerep = relposreps{end};
rootrp = lastmergerep(:,1);
obblist(10,end) = rootrp(2);
obblist(12,end) = rootrp(3);
for i = nodenum:-1:1
    pobb = obblist(:,i);
    k = kids{i};
    rplist = relposreps{i};
    if(length(k)>1)
        for j = 2:length(k)
            rp = rplist(:,j-1);
            cobb = genOBBfrom2dOffset( pobb, rp );
            obblist(:,k(j)) = cobb;
        end
    end
end

% form the data
data.kids = kids;
data.labellist = labellist;
data.obblist = obblist;%(:,1:leafnum);
if(exist('layers','var'))
    data.layers = layers;
end

end

