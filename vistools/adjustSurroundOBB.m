function [ trans1, trans2, trans3, pobb ] = adjustSurroundOBB( obb1,obb2,obb3,mparam )
%ADJUSTSURROUNDOBB 
% adjust the positions of three boxes based on the alignments
%
% INPUT: obb1, obb2, obb3  - the three boxes in 3d absolute position format
%        mparam  - the alignment, which two edges are aligned
%
% OUTPUT: trans1, trans2, trans3  - the translation of three boxes
%         pobb  - the absolute position of their parent

trans1 = [0;0;0];

% transform to 2d
cent1 = obb1([1,3]);
front1 = obb1([4,6]);
axes1 = [-front1(2);front1(1)];
size1 = obb1([10,12]);

cent2 = obb2([1,3]);
front2 = obb2([4,6]);
axes2 = [-front2(2);front2(1)];
size2 = obb2([10,12]);

cent3 = obb3([1,3]);
front3 = obb3([4,6]);
axes3 = [-front3(2);front3(1)];
size3 = obb3([10,12]);

%% move the second box based on the central box (box1)
edge1 = mparam(1);
edge2 = mparam(2);

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

if((pos1-pos2)'*dir2<0)
    dir2 = -dir2;
end

if(norm(abs(dir1)-abs(dir2),2)<0.01)
    len = (pos1-pos2)'*dir2;
    trans2 = len*dir2;
    trans2 = [trans2(1);0;trans2(2)];
    obb2(1:3) = obb2(1:3)+trans2;
else
    trans2 = [0;0;0];
end


%% move the thrid box based on the central box (box1)
edge1 = mparam(3);
edge3 = mparam(4);

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

switch(edge3)
    case 1
        dir3 = front3;
        pos3 = cent3 + dir3*size3(1)/2;
    case 2
        dir3 = axes3;
        pos3 = cent3 + dir3*size3(2)/2;
    case 3
        dir3 = front3;
        pos3 = cent3 - dir3*size3(1)/2;
    case 4
        dir3 = axes3;
        pos3 = cent3 - dir3*size3(2)/2;
end

if((pos1-pos3)'*dir3<0)
    dir3 = -dir3;
end

if(norm(abs(dir1)-abs(dir3),2)<0.01)
    len = (pos1-pos3)'*dir3;
    trans3 = len*dir3;
    trans3 = [trans3(1);0;trans3(2)];
    obb3(1:3) = obb3(1:3)+trans3;
else
    trans3 = [0;0;0];
end

pobb = updateOBB([obb1,obb2,obb3],[1,2,3]);
end

