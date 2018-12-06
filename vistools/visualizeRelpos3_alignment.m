function [ obblist, labellist ] = visualizeRelpos3_alignment( kids, mergereps, leafreps, params, labelset )
%VISUALIZERELPOS3_ALIGNMENT 
% to visualize the absolute position of objects
% from the relative position respecting to its parents
% the layout needs to be adjust based on the "same orientation" and "alignment"
%
% the default setting is 2D, one-hot label vectors
%
% INPUT: kids, mergereps, leafreps, params   - the data to be visualized
%        labelset  - the name of the categories (order matters)
%
% OUTPUT: obblist  - the 3d obblist of all the leaves
%         labellist  - labels of all the leaves

dim = 2;
BOX = 0;
SUPPORT = 1;
GROUP = 2;
SURROUND = 3;

LABELLEN = length(labelset);
labeldefs = zeros(LABELLEN, LABELLEN);
for i = 1:LABELLEN
    labeldefs(i,i) = 1;
end

% transform the layers to discrete values
layers = [0.2,0.4,0.6,0.8,1];
for i = 1:size(leafreps,2)
    dist = abs(layers - leafreps(3,i));
    [~,I] = min(dist);
    leafreps(3,i) = layers(I)*5;
end

% transform the labels to one-hot labels
labellist = {};
for i = 1:size(leafreps,2)
    label = leafreps(4:end,i);
    [~,I] = max(label);
    leafreps(4:end,i) = labeldefs(:,I);
    labellist{length(labellist)+1} = labelset{I};
end

% back propagate the positions
rcent = [0;0]; % root center
rfront = [1;0]; % root front
framelist = zeros(4,length(kids));
framelist(:,length(kids)) = [rcent;rfront];
for i = length(kids):-1:1
    k = kids{i};
    frame = framelist(:,i);
    pcent = frame(1:2);
    pfront = frame(3:4);
    paxes = [-pfront(2);pfront(1)];
    transform = [pfront(:)';paxes(:)'];
%     transform = inv(transform);
    
    rps = mergereps{i};
    for j = 2:length(k)
        ind = k(j);
        rp = rps(:,j-1);
        
        % adjust the orientation
        sameori = rp(end);
        gtori = [-1,0,1];
        dist = abs(sameori - gtori);
        [~,I] = min(dist);
        sameori = gtori(I);
        if(sameori==1)
            rp(3:4) = [1;0];
        end
        if(sameori==-1)
            rp(3:4) = [-1;0];
        end
        
        ccent = rp(1:2);
        cfront = rp(3:4);
        cfront = cfront/norm(cfront,2);
        ncent = transform\ccent;
        ncent = ncent + pcent;
        nfront = transform\cfront;
        nfront = nfront/norm(nfront,2);
        nframe = [ncent;nfront];
        framelist(:,ind) = nframe;
    end
end

obblist = [];
for i = 1:length(kids)
    k = kids{i};
    if(k(1)==0)
        frame = framelist(:,i);
        leaf = leafreps(:,i);
        obb = [frame(1);0;frame(2);frame(3);0;frame(4);0;1;0;leaf(1);0;leaf(2)];
        obblist = [obblist,obb];
    end
end

%% forward propagate to adjust the alignments
translationlist = cell(length(kids),1);
nobblist = zeros(size(obblist,1),length(kids));
gtparam = [0,0.25,0.5,0.75,1];
for i = 1:length(kids)
    k = kids{i};
    flag = k(1);
    mparam = params{i};
    for j = 1:length(mparam)
       dist = abs(mparam(j)- gtparam);
       [~,I] = min(dist);
       mparam(j) = gtparam(I)*4;
    end
    if(flag==BOX)
        translationlist{i} = [0;0;0];
        obb = obblist(:,i);
        nobblist(:,i) = obb;
    end
    if(flag==SUPPORT)
        translationlist{i} = [0;0;0];
        list = k(2:end);
        nobblist(:,i) = updateOBB(nobblist,list);
    end
    if(flag==GROUP)
        if(all(mparam>0))
            obb1 = nobblist(:,k(2));
            obb2 = nobblist(:,k(3));
            [trans1, trans2, pobb] = adjustGroupOBB(obb1,obb2,mparam);
            translationlist{k(2)} = translationlist{k(2)} + trans1;
            translationlist{k(3)} = translationlist{k(3)} + trans2;
            translationlist{i} = [0;0;0];
            nobblist(:,i) = pobb;
        else
            translationlist{i} = [0;0;0];
            list = k(2:end);
            nobblist(:,i) = updateOBB(nobblist,list);
        end
    end
    if(flag==SURROUND)
        if(all(mparam>0))
            obb1 = nobblist(:,k(2));
            obb2 = nobblist(:,k(3));
            obb3 = nobblist(:,k(4));
            [trans1, trans2, trans3, pobb] = adjustSurroundOBB(obb1,obb2,obb3,mparam);
            translationlist{i} = [0;0;0];
            translationlist{k(2)} = translationlist{k(2)} + trans1;
            translationlist{k(3)} = translationlist{k(3)} + trans2;
            translationlist{k(4)} = translationlist{k(4)} + trans3;
            nobblist(:,i) = pobb;
        else
            translationlist{i} = [0;0;0];
            list = k(2:end);
            nobblist(:,i) = updateOBB(nobblist,list);
        end
    end
end

for i = length(kids):-1:1
    trans = translationlist{i};
    k = kids{i};
    list = k(2:end);
    for j = 1:length(list)
        ctrans = translationlist{list(j)};
        ctrans = ctrans+trans;
        translationlist{list(j)} = ctrans;
    end
end

for i = 1:size(obblist,2)
    obb = obblist(:,i);
    trans = translationlist{i};
    obb(1) = obb(1)+trans(1);
    obb(3) = obb(3)+trans(3);
    obblist(:,i) = obb;
end

end

