function [ maxx, maxy, minx, miny, nfront, ncmaxx, ncmaxy, ncminx, ncminy ] = genCorFrom2dOffset_v2( rp, size1, size2 )
%GENSIZEFROM2DOFFSET_V2 
% given the sizes of two children and their relative position rp
% compute the coordinates of their parent

% adjust the orientation
degree = rp(1);
degree = (degree+1)*180;
nfront(1,1) = cosd(degree);
nfront(3,1) = sind(degree);

alignment = rp(24:28);
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

% coordinates of box 1
pmaxx = size1(1)/2;
pminx = -size1(1)/2;
pmaxy = size1(2)/2;
pminy = -size1(2)/2;

offsets = rp(2:3);
attachvec = rp(20:23);
[~,attachindex] = max(attachvec);
if(mod(attachindex-1,2)==1)
    offsets(1) = 0;
end
if(floor((attachindex-1)/2)==1)
    offsets(2) = 0;
end

classvec = rp(4:19);
[~,classindex] = max(classvec);
classxindex = mod(classindex,4);
if(classxindex==0)
    classxindex=4;
end
classyindex = floor((classindex-1)/4)+1;

csize = [size2(1);0;size2(2)];
nsize = abs(csize(1)*nfront) + abs(csize(3)*naxes);

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

% nup = [0;1;0];
% ccent = [(cmaxx+cminx)/2;0;(cmaxy+cminy)/2];
% cobb = [ccent;nfront;nup;(cmaxx-cminx);0;(cmaxy-cminy)];
% cornerpoints = OBBrep2cornerpoints( cobb );
% 
% ncmaxx = max(cornerpoints(:,1));
% ncmaxy = max(cornerpoints(:,3));
% ncminx = min(cornerpoints(:,1));
% ncminy = min(cornerpoints(:,3));
ncmaxx = cmaxx;
ncmaxy = cmaxy;
ncminx = cminx;
ncminy = cminy;

maxx = max(pmaxx,ncmaxx);
maxy = max(pmaxy,ncmaxy);
minx = min(pminx,ncminx);
miny = min(pminy,ncminy);

end

