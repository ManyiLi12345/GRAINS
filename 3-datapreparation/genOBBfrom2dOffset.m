function [ cobb ] = genOBBfrom2dOffset( pobb, rp )
%GENOBBFROM2DOFFSET generate box with absolute position from offset format
% 
% INPUT: pobb - the parent box with absolute position.
%               rp - relative position (offsets) of child box under its
%               parent's local frame, including:
%                    (1) relative orientation - 1 bit
%                    (2) absolute sizes (under its local frame) - 2 bits
%                    (3) offsets - 2 bits
%                    (4) 4 classes (the relative layout, which two edges are close) - 4 bits
%                    (5) attachments (4 possible cases) - 4 bits
%                    (6) alignment (whether they are aligned or not) - 1 bit
%
% OUTPUT: cobb - the child box with absolute position

% relpos = [nfront(1);csize(1);csize(3);offsets(1);offsets(2);classvec;alignvec];

csize = [rp(2);0;rp(3)];
offsets = [rp(4);rp(5)];
classvec = rp(6:9);
[~,classindex] = max(classvec);
attachvec = rp(10:13);
[~,attachindex] = max(attachvec);
alignment = rp(14);

if(abs(alignment)>0.5)
    if(abs(rp(1))<0.5)
        rotation = 0;
    else
        rotation = 1;
    end
else
    rotation = rp(1);
end            
nfront =  [rotation;0;sqrt(1-rotation*rotation)];

% use the alignment to adjust the offsets
if(mod(attachindex-1,2)==1)
    offset(1) = 0;
end
if(floor((attachindex-1)/2)==1)
    offset(2) = 0;
end

% parent box info
pcent = pobb(1:3);
pfront = pobb(4:6);
pup = pobb(7:9);
psize = pobb(10:12);
paxes = cross(pfront,pup);
paxes = paxes/norm(paxes,2);
transform = genTransMat(pfront,pup);
transform = inv(transform);

% child box info
cfront = transform*nfront;
cfront = abs(cfront);% assume all elements in orientation vec are positive
cup = [0;1;0];
caxes = cross(cfront,cup);
caxes = caxes/norm(caxes,2);

% parent edges info
pminx = -psize(1)/2;
pmaxx = psize(1)/2;
pminy = -psize(3)/2;
pmaxy = psize(3)/2;

if(mod(classindex-1,2)==0)
    cmaxx = pmaxx - offsets(1);
    cminx = cmaxx - csize(1);
else
    cminx = pminx + offsets(1);
    cmaxx = cminx + csize(1);
end
if(floor((classindex-1)/2)==0)
    cmaxy = pmaxy - offsets(2);
    cminy = cmaxy - csize(3);
else
    cminy = pminy + offsets(2);
    cmaxy = cminy + csize(3);
end

ncent = [(cmaxx+cminx)/2;0;(cmaxy+cminy)/2];
ccent = transform*ncent + pcent;
cobb = [ccent;cfront;cup;csize];

end

