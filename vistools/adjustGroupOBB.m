function [ trans1, trans2, pobb ] = adjustGroupOBB( obb1, obb2, mparam )
%ADJUSTGROUPOBB 
% adjust the positions of two boxes based on the alignments
%
% INPUT: obb1, obb2  - the two boxes in 3d absolute position format
%        mparam  - the alignment, which two edges are aligned
% OUTPUT: trans1, trans2  - the translation of two boxes
%         pobb  - the absolute position of their parent

edge1 = mparam(1);
edge2 = mparam(2);

% transform to 2d
cent1 = obb1([1,3]);
front1 = obb1([4,6]);
axes1 = [-front1(2);front1(1)];
size1 = obb1([10,12]);

cent2 = obb2([1,3]);
front2 = obb2([4,6]);
axes2 = [-front2(2);front2(1)];
size2 = obb2([10,12]);

% compute the directions to move
switch(edge1)
    case 1
        dir1 = front1;
        pos1 = cent1 + dir1*size1(1)/2;
    case 2
        dir1 = axes1;
        pos1 = cent1 + dir1*size1(2)/2;
    case 3
        dir1 = front1;
        pos1 = cent1 - dir1*size1(1)/2;
    case 4
        dir1 = axes1;
        pos1 = cent1 - dir1*size1(2)/2;
end

switch(edge2)
    case 1
        dir2 = front2;
        pos2 = cent2 + dir2*size2(1)/2;
    case 2
        dir2 = axes2;
        pos2 = cent2 + dir2*size2(2)/2;
    case 3
        dir2 = front2;
        pos2 = cent2 - dir2*size2(1)/2;
    case 4
        dir2 = axes2;
        pos2 = cent2 - dir2*size2(2)/2;
end

midpos = (pos1+pos2)/2;
if((midpos-pos1)'*dir1<0)
    dir1 = -dir1;
end
if((midpos-pos2)'*dir2<0)
    dir2 = -dir2;
end


if(norm(dir1+dir2,2)<0.01)
    len1 = (midpos-pos1)'*dir1;
    len2 = (midpos-pos2)'*dir2;
    trans1 = len1*dir1;
    trans2 = len2*dir2;
    trans1 = [trans1(1);0;trans1(2)];
    trans2 = [trans2(1);0;trans2(2)];
    obb1(1:3) = obb1(1:3)+trans1;
    obb2(1:3) = obb2(1:3)+trans2;
    pobb = updateOBB([obb1,obb2],[1,2]);
    return
end


trans1 = [0;0;0];
trans2 = [0;0;0];
pobb = updateOBB([obb1,obb2],[1,2]);

end

