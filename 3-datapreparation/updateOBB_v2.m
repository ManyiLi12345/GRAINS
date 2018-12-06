function [ pobb ] = updateOBB_v2( obb1, obb2 )
%UPDATEOBB_V2 update the parent obb of two children box
% the parent obb's orientation is inherit from obb1
%
% INPUT: obb1 - box1 with absolute position
%        obb2 - box2 with absolute position
%
% OUTPUT: pobb - parent box with absolute position
%
    c = obb1(1:3);
    front = obb1(4:6);
    up = obb1(7:9);
    transform = genTransMat(front,up);

    cornerpoints = OBBrep2cornerpoints(obb1);
    cornerpoints = cornerpoints-repmat(c',size(cornerpoints,1),1);
    cornerpoints = transform*cornerpoints';
    maxp = max(cornerpoints');
    minp = min(cornerpoints');
    
    cornerpoints = OBBrep2cornerpoints(obb2);
    cornerpoints = cornerpoints-repmat(c',size(cornerpoints,1),1);
    cornerpoints = transform*cornerpoints';
    maxp = max([maxp;cornerpoints']);
    minp = min([minp;cornerpoints']);
    
    cent = (maxp+minp)/2;
    axes = cross(front,up);
    axes = axes/norm(axes,2);
    cent = c+cent(1)*front+cent(2)*up+cent(3)*axes;

    s = (maxp-minp);
    pobb = [cent(:);front;up;s(:)];

end

