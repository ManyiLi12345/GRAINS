function [ robb ] = updateOBB( obblist, ind )
%UPDATEOBB 
obblist = obblist(:,ind);
obbcanlist = zeros(size(obblist,1),length(ind));
diadists = zeros(1,length(ind));
for i = 1:size(obblist,2)
    % use the orientation of obb_i
    obb = obblist(:,i);
    c = obb(1:3);
    front = obb(4:6);
    up = obb(7:9);
%     axes = cross(front,up);
%     axes = axes/norm(axes,2);
%     transform = [front,up,axes];
    transform = genTransMat(front,up);

    maxp = [];
    minp = [];
    for j = 1:size(obblist,2)
        cornerpoints = OBBrep2cornerpoints(obblist(:,j));
        cornerpoints = cornerpoints-repmat(c',size(cornerpoints,1),1);
        cornerpoints = transform*cornerpoints';
        maxp = max([maxp;cornerpoints']);
        minp = min([minp;cornerpoints']);
    end

    % transform back to global frame
%     ap = [0;0;0];
%     transform = [transform,ap];
%     ap = [0,0,0,1];
%     transform = [transform;ap];
    cent = (maxp+minp)/2;
    axes = cross(front,up);
    axes = axes/norm(axes,2);
    cent = c+cent(1)*front+cent(2)*up+cent(3)*axes;
%     cent = cent(:);
%     cent = transform*cent;

    s = (maxp-minp);
    robb = [cent(:);front;up;s(:)];
    diadists(i) = norm(s,2);
    obbcanlist(1:length(robb),i) = robb;
end

[~,I] = min(diadists);
robb = obbcanlist(:,I(1));

end

