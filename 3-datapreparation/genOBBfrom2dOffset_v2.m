function [ cobb ] = genOBBfrom2dOffset_v2( pobb, rp )
%GENOBBFROM2DOFFSET_V2 generate box with absolute position from offset format
% 
% INPUT: pobb - the parent box with absolute position.
%               rp - relative position (offsets) of child box under its
%               parent's local frame, including:
%                    (1) relative orientation - 1 bit
%                    (2) absolute sizes (under its local frame) - 2 bits
%                    (3) offsets - 2 bits
%                    (4) 16 classes (4 classes along each axis) - 8 bits
%                    (5) attachments (4 possible cases) - 4 bits
%                    (6) alignment (whether they are aligned or not) - 1 bit
%
% OUTPUT: cobb - the child box with absolute position

% relpos = [nfront(1);csize(1);csize(3);offsets(1);offsets(2);classvec;alignvec];
csize = [rp(2);rp(3)];
offsets = [rp(4);rp(5)];
classvec = rp(6:21);
[~,classindex] = max(classvec);
classxindex = mod(classindex,4);
if(classxindex==0)
    classxindex=4;
end
classyindex = floor((classindex-1)/4)+1;
attachvec = rp(22:25);
[~,attachindex] = max(attachvec);

degree = rp(1);
degree = (degree+1)*180;
nfront(1,1) = cosd(degree);
nfront(3,1) = sind(degree);

alignment = rp(26:30);
[~,alignindex] = max(alignment);
switch(alignindex)
    case 2
        nfront = [1;0;0];
    case 3
        nfront = [-1;0;0];
    case 4
        nfront = [0;0;1];
    case 5
        nfront = [0;0;-1];
end
nup = [0;1;0];
naxes = cross(nfront,nup);
naxes = naxes/norm(naxes,2);

% use the alignment to adjust the offsets
if(mod(attachindex-1,2)==1)
    offsets(1) = 0;
end
if(floor((attachindex-1)/2)==1)
    offsets(2) = 0;
end

% if(abs(rotation)<0.5)
%     offsets = [offsets(2);offsets(1)];
% end

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
cup = [0;1;0];
caxes = cross(cfront,cup);
caxes = caxes/norm(caxes,2);
csize = [csize(1);0;csize(2)];
nsize = abs(csize(1)*nfront) + abs(csize(3)*naxes);

% parent edges info
pminx = -psize(1)/2;
pmaxx = psize(1)/2;
pminy = -psize(3)/2;
pmaxy = psize(3)/2;

switch(classxindex)
    case 1
        cmaxx = pminx - offsets(1);
        cminx = cmaxx - abs(nsize(1));
    case 2
        cminx = pminx - offsets(1);
        cmaxx = cminx + abs(nsize(1));
    case 3
        cmaxx = pmaxx - offsets(1);
        cminx = cmaxx - abs(nsize(1));
    case 4
        cminx = pmaxx - offsets(1);
        cmaxx = cminx + abs(nsize(1));
end

switch(classyindex)
    case 1
        cmaxy = pminy - offsets(2);
        cminy = cmaxy - abs(nsize(3));
    case 2
        cminy = pminy - offsets(2);
        cmaxy = cminy + abs(nsize(3));
    case 3
        cmaxy = pmaxy - offsets(2);
        cminy = cmaxy - abs(nsize(3));
    case 4
        cminy = pmaxy - offsets(2);
        cmaxy = cminy + abs(nsize(3));
end

ncent = [(cmaxx+cminx)/2;0;(cmaxy+cminy)/2];
ccent = transform*ncent + pcent;
% ccent = ncent + pcent;
cobb = [ccent;cfront;cup;csize];


end

