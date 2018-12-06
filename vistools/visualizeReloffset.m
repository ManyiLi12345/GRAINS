function [ obblist, labellist ] = visualizeReloffset( leafreps, labeldefs, dim )
%VISUALIZERELPOS 
% this function only considers the artificial dataset: exact one bed, no
% more than two objects in each category
classnum = 7;
if(dim==2)
    % turn the relpos into 3D
    nleafreps = zeros(classnum*(dim+1)*2+classnum,size(leafreps,2));
    for i = 1:classnum
        nleafreps((i-1)*(dim+1)*2+1,:) = leafreps((i-1)*dim*2+1,:);
        nleafreps((i-1)*(dim+1)*2+3,:) = leafreps((i-1)*dim*2+2,:);
        nleafreps((i-1)*(dim+1)*2+4,:) = leafreps((i-1)*dim*2+3,:);
        nleafreps((i-1)*(dim+1)*2+6,:) = leafreps((i-1)*dim*2+4,:);
    end
    nleafreps(end-classnum+1:end,:) = leafreps(end-classnum+1:end,:);
    leafreps = nleafreps;
end

offsetnum = 6;
objnum = size(leafreps,2);
relvecs = leafreps(1:classnum*offsetnum,:);
labelvecs = leafreps(classnum*offsetnum+1:end,:);

% recon the size
objsizelist = zeros(offsetnum/2,objnum);
for i = 1:objnum
    rv = relvecs(:,i);
    
    sizelist = [];
    for j = 1:classnum
        rvj = rv((j-1)*offsetnum+1:j*offsetnum);
        if(~all(rvj==0))
            sizelist = [sizelist,rvj(1:offsetnum/2)-rvj(offsetnum/2+1:end)];
        end
    end
    si = mean(sizelist');
    
    objsizelist(:,i)=si(:);
end

% assume there's only one bed and located in [0,0]
bed_label = labeldefs(:,1);
dist = zeros(objnum,1);
for i = 1:objnum
    label = labelvecs(:,i);
    dis = norm(label-bed_label,2);
    dist(i) = dis;
end
[~,I] = min(dist);
bed_index = I;

obblist = zeros(12,objnum);
info = relvecs(1:offsetnum,:);% we only use the relpos of each object relative to the bed, based on the assumption
% actually, the redundancy will cause mess.
bedminp = [0;0;0]-objsizelist(:,bed_index);
anchor = [bedminp/2;bedminp/2];
for i = 1:objnum
    bbox = info(:,i)+anchor;
    maxp = bbox(1:offsetnum/2);
    minp = bbox(offsetnum/2+1:end);
    
%     maxp = [maxp(1);0.1;maxp(2)];
%     minp = [minp(1);0;minp(2)];
    cent = (maxp+minp)/2;
    orient = [1;0;0;0;1;0];
    s = maxp-minp;
    obb = [cent;orient;s];
    obblist(:,i) = obb;
end

% recon the labellist
tlabellist = {'bed','stand','lamp','rug','ottoman','person','floor'};
labellist = {};
for i = 1:objnum
    label = labelvecs(:,i);
    dist = zeros(classnum,1);
    for j = 1:classnum
        clabel = labeldefs(:,j);
        dis = norm(label-clabel,2);
        dist(j) = dis;
    end
    [~,I] = min(dist);
    labellist{length(labellist)+1} = tlabellist{I};
end


end

