function [ relpos, psize3, delta_midy ] = gen2dOffset_v2( box1, box2, issplitting )
%GEN2DOFFSET_V2 compute the rotation and offsets between two sibling boxes
% INPUT: box1, box2 - 3d box of base box with absolute position
%
% OUTPUT: relpos - 13d vector (rp of box2 relative to box1), including:
%                    (1) relative orientation - 1 bit degree
%                    (3) offsets - 2 bits
%                    (4) 16 classes (4 classes along each axis) - 8 bits
%                    (5) attachments (4 possible cases) - 4 bits
%                    (6) alignments (aligned along each axis) - 2 bit

% box1 info
pcent = box1(1:3);
pfront = box1(4:6);
pup = box1(7:9);
psize = box1(10:12);
paxes = cross(pfront,pup);
paxes = paxes/norm(paxes,2);

% box2 info
ccent = box2(1:3);
cfront = box2(4:6);
cup = box2(7:9);
csize = box2(10:12);
caxes = cross(cfront,cup);
caxes = caxes/norm(caxes,2);

transform = genTransMat(pfront,pup);
ncent = ccent-pcent;
ncent = transform*ncent; % child's center position in parent's local frame
nfront = cfront;
nfront = transform*nfront; % child's front direction in parent's local frame
nfront = nfront/norm(nfront,2);
nup = cup;
nup = transform*nup; % child's up direction in parent's local frame
nup = nup/norm(nup,2);
naxes = cross(nfront,nup);
naxes = naxes/norm(naxes,2);

% 4 corner points of parent box under its own local frame
plfront = [1;0;0];
plaxes = [0;0;1];
ppoints(:,1) = psize(1)*plfront/2 + psize(3)*plaxes/2;
ppoints(:,2) = psize(1)*plfront/2 - psize(3)*plaxes/2;
ppoints(:,3) = -psize(1)*plfront/2 - psize(3)*plaxes/2;
ppoints(:,4) = -psize(1)*plfront/2 + psize(3)*plaxes/2;

% 4 corner points of child box under its parent's local frame
cpoints(:,1) = ncent + csize(1)*nfront/2 + csize(3)*naxes/2;
cpoints(:,2) = ncent + csize(1)*nfront/2 - csize(3)*naxes/2;
cpoints(:,3) = ncent - csize(1)*nfront/2 - csize(3)*naxes/2;
cpoints(:,4) = ncent - csize(1)*nfront/2 + csize(3)*naxes/2;

% the relative positions
pmaxx = max(ppoints(1,:));
pmaxy = max(ppoints(3,:));
pminx = min(ppoints(1,:));
pminy = min(ppoints(3,:));
cmaxx = max(cpoints(1,:));
cmaxy = max(cpoints(3,:));
cminx = min(cpoints(1,:));
cminy = min(cpoints(3,:));

delta_midy = 0;
if(issplitting==1)
    pmidy = (pmaxy+pminy)/2;
    cmidy = (cmaxy+cminy)/2;
    delta_midy = pmidy-cmidy;
    pmaxy = cmaxy;
    pminy = cminy;
end
psize3 = pmaxy-pminy;

% relative position class along x axis
delta_x = [pminx-cmaxx;pminx-cminx;pmaxx-cmaxx;pmaxx-cminx];
[~,classxindex] = min(abs(delta_x));
offsets(1) = delta_x(classxindex);

% relative position class along y axis
delta_y = [pminy-cmaxy;pminy-cminy;pmaxy-cmaxy;pmaxy-cminy];
[~,classyindex] = min(abs(delta_y));
offsets(2) = delta_y(classyindex);

% alignment info
attachindex = 1;
attacheps = 0.011; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(abs(offsets(1))<attacheps)
    attachindex = attachindex + 1;
end
if(abs(offsets(2))<attacheps)
    attachindex = attachindex + 2;
end
attachvec = zeros(4,1);
attachvec(attachindex) = 1;

% form the relpos vector
rot_eps = 0.01;
alignment = [1;0;0;0;0];
if(abs(nfront(1)-1)<rot_eps)
    alignment = [0;1;0;0;0]; % nfront = [1,0,0];
end 
if(abs(nfront(1)+1)<rot_eps)
    alignment = [0;0;1;0;0]; % nfront = [-1,0,0];
end 
if(abs(nfront(3)-1)<rot_eps)
    alignment = [0;0;0;1;0]; % nfront = [0,0,1];
end 
if(abs(nfront(3)+1)<rot_eps)
    alignment = [0;0;0;0;1]; % nfront = [0,0,-1];
end 

if(nfront(1)==0)
    if(nfront(3)>0)
        degree = -0.5;
    else
        degree = 0.5;
    end
else
    degree = atand(nfront(3)/nfront(1));
    if(nfront(1)<0)
        if(degree<0)
            degree = degree-180;
        else
            degree = degree+180;
        end
    end
    degree = mod(degree,360)/180-1;
end
if(abs(degree)>1)
        o=0;
    end

classindex = classxindex + (classyindex-1)*4;
classvec = zeros(16,1);
classvec(classindex) = 1;
relpos = [degree;offsets(1);offsets(2);classvec;attachvec;alignment];

% tmpcent = pcent;
% tmpfsize = (max(cmaxx,pmaxx)-min(cminx,pminx));
% tmpasize = (max(cmaxy,pmaxy)-min(cminy,pminy));
% tmpobb = [tmpcent;plfront;0;1;0;tmpfsize;1;tmpasize];
% draw3dOBB_v2(box1,'r');
% draw3dOBB_v2(box2,'g');
% draw3dOBB_v2(tmpobb,'y');

end

