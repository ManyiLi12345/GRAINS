function [ obblist, labellist ] = visualizeAbspos( leafreps, labeldefs, labelset, dim  )

classnum = length(labelset);
obbnum = size(leafreps,2);
padding = zeros(1,obbnum);

if(dim==2)
    obblist = [leafreps(1,:);padding;leafreps(2:3,:);padding;leafreps(4,:);padding;padding+1;padding;leafreps(5,:);padding;leafreps(6:end,:)];
else
    obblist = leafreps;
end

for i = 1:size(obblist,2)
    obb = obblist(:,i);
    cent = obb(1:3);
    front = obb(4:6);
    up = obb(7:9);
    sizes = obb(10:12);
    
    front = front/norm(front,2);
    up = up/norm(up,2);
    obb = [cent;front;up;sizes];
    obblist(:,i) = obb;
end

% for v = 1:size(obblist,2)
%     draw3dOBB_v2(obblist(:,v),'k');
% end

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

