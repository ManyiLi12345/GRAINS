function [ obblist, labellist ] = visualizeReltransform( leafreps, labeldefs, labelset, dim )

classnum = length(labelset);
if(dim==2)
    % turn the relpos into 3D
    nleafreps = zeros(classnum*9+classnum+3,size(leafreps,2));
    for i = 1:classnum
        nleafreps((i-1)*9+1,:) = leafreps((i-1)*4+1,:);
        nleafreps((i-1)*9+3,:) = leafreps((i-1)*4+2,:);
        nleafreps((i-1)*9+4,:) = leafreps((i-1)*4+3,:);
        nleafreps((i-1)*9+6,:) = leafreps((i-1)*4+4,:);
        nleafreps((i-1)*9+8,:) = 1;
    end
    nleafreps(end-classnum-3+1,:) = leafreps(end-classnum-2+1,:);
    nleafreps(end-classnum-1+1:end,:) = leafreps(end-classnum-1+1:end,:);
    leafreps = nleafreps;
end

offsetnum = 9;
objnum = size(leafreps,2);
relvecs = leafreps(1:classnum*offsetnum,:);
objsizelist = leafreps(classnum*offsetnum+1:classnum*offsetnum+3,:);
labelvecs = leafreps(classnum*offsetnum+3+1:end,:);


% assume there's only one bed and located in [0,0]
floor_index = size(labeldefs,2);

obblist = zeros(12,objnum);
info = relvecs(offsetnum*(floor_index-1)+1:offsetnum*floor_index,:);% we only use the relpos of each object relative to the bed, based on the assumption
% actually, the redundancy will cause mess.
floor_cent = [0,0,0];
floor_front = [1,0,0];
floor_up = [0,1,0];
floor_axes = [0,0,1];
[ transform ] = genTransMat( floor_front, floor_up );
for i = 1:objnum
    cent = info(1:3,i);
    cent = floor_cent' - cent;
    front = info(4:6,i);
    up = info(7:9,i);
    axes = cross(front,up);
    axes = axes/norm(axes);
    mat = [front,up,axes];
    front = mat(1,:);
    up = mat(2,:);
    cent = inv(mat)*cent;
    s = objsizelist(:,i);
    obb = [cent(:);front(:);up(:);s];
    obblist(:,i) = obb;
end

% recon the labellist
tlabellist = labelset;
labellist = {};
for i = 1:objnum
    label = labelvecs(:,i);
	[~,I] = max(label);
	labellist{length(labellist)+1} = tlabellist{I};
end

end

