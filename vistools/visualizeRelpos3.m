function [ obblist, labellist ] = visualizeRelpos3( kids, mergereps, leafreps, labeldefs, labelset, dim )
%VISUALIZERELPOS3
% to visualize the absolute positions of objects
% from the relative position respecting to its parent
%
% INPUT:  kids, mergereps, leafreps   - the data to be visualized
%                dim     - the input data are in 2d or 3d
%                labeldefs    - the definition of vectors for all the labels
%                labeltype   - 1: onehot, 2: word embedding by cooccurrence
%
% OUTPUT:  obblist - the 3D obblist of all the leaves
%                     labellist - labels of all the leaves

% if the input is 2D data, just fill in some values to make it 3D
% labelset = {'bed','stand','lamp','rug','ottoman','person','floor'};
classnum = length(labelset);
if(dim==2)
	%turn the relpos into 3D
    for i = 1:length(mergereps)
        rps = mergereps{i};
        if(size(rps,2)>0)
            padding = zeros(1,size(rps,2));
            rps = [rps(1,:);padding;rps(2,:);rps(3,:);padding;rps(4,:);padding;padding+1;padding];
        end
        mergereps{i} = rps;
    end
    padding = zeros(1,size(leafreps,2));
    leafreps = [leafreps(1,:);padding+0.1;leafreps(2:end,:)];
end

% suppose the root has the global frame
gcent = [0;0;0];
gfront = [1;0;0];
gup = [0;1;0];

% back propagate to compute the frame of each node
framelist = zeros(9,length(kids));
framelist(:,length(kids)) = [gcent;gfront;gup];
for i = length(kids):-1:1
    k = kids{i};
    frame = framelist(:,i);
    cent = frame(1:3);
    front = frame(4:6);
    up = frame(7:9);
    transform = genTransMat(front,up);
    transform = inv(transform);
    
    rps = mergereps{i};
    for j = 2:length(k)
        ind = k(j);
        rp = rps(:,j-1);
        ccent = rp(1:3);
        cfront = rp(4:6);
        cup = rp(7:9);
        
        cfront = cfront/norm(cfront,2);
        cup = cup/norm(cup,2);
        
        ncent = transform*ccent;
        ncent = ncent+cent;
        nfront = transform*cfront;
        nup = transform*cup;
        
        nfront = nfront/norm(nfront,2);
        nup = nup/norm(nup,2);
        nframe = [ncent;nfront;nup];
        framelist(:,ind) = nframe;
    end
end

obblist = [];
for i = 1:length(kids)
    k = kids{i};
    if(k(1)==0)
        frame = framelist(:,i);
        
        leaf = leafreps(:,i);
        obb = [frame(1:9);leaf(1:3)];
        obblist = [obblist,obb];
    end
end

% recon the labellist
% tlabellist = {'bed','stand','lamp','rug','ottoman','person','floor'};
tlabellist = labelset;
labellist = {};
objnum = size(leafreps,2);
labelvecs = leafreps(end-classnum+1:end,:);
for i = 1:objnum
	label = labelvecs(:,i);
	[~,I] = max(label);
	labellist{length(labellist)+1} = tlabellist{I};
end



end

