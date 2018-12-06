function [ relpos ] = gen2dOffset( pobb, cobb )
%GEN2DOFFSET compute the rotation and offsets between two boxes
% INPUT: pobb - 3d box of parent box with absolute position
%        cobb - 3d box of child box with absolute position
%
% OUTPUT: relpos - 13d vector, including:
%                    (1) relative orientation - 1 bit
%                    (2) absolute sizes (under its local frame) - 2 bits
%                    (3) offsets - 2 bits
%                    (4) 4 classes (the relative layout, which two edges are close) - 4 bits
%                    (5) attachments (4 possible cases) - 4 bits
%                    (6) alignments (whether aligned or not) - 1 bit

% parent box info
pcent = pobb(1:3);
pfront = pobb(4:6);
pup = pobb(7:9);
psize = pobb(10:12);
paxes = cross(pfront,pup);
paxes = paxes/norm(paxes,2);

% child box info
ccent = cobb(1:3);
cfront = cobb(4:6);
cup = cobb(7:9);
csize = cobb(10:12);
caxes = cross(cfront,cup);
caxes = caxes/norm(caxes,2);

transform = genTransMat(pfront,pup);
ncent = ccent-pcent;
ncent = transform*ncent; % child's center position in parent's local frame
nfront = cobb(4:6);
nfront = transform*nfront; % child's front direction in parent's local frame
nfront = nfront/norm(nfront,2);
% nup = cobb(7:9);
% nup = transform*nup; % child's up direction in parent's local frame

% 4 corner points of parent box under its own local frame
plfront = [1;0;0];
plaxes = [0;0;1];
ppoints(:,1) = psize(1)*plfront/2 + psize(3)*plaxes/2;
ppoints(:,2) = psize(1)*plfront/2 - psize(3)*plaxes/2;
ppoints(:,3) = -psize(1)*plfront/2 - psize(3)*plaxes/2;
ppoints(:,4) = -psize(1)*plfront/2 + psize(3)*plaxes/2;

% 4 corner points of child box under its parent's local frame
cpoints(:,1) = ncent + csize(1)*plfront/2 + csize(3)*plaxes/2;
cpoints(:,2) = ncent + csize(1)*plfront/2 - csize(3)*plaxes/2;
cpoints(:,3) = ncent - csize(1)*plfront/2 - csize(3)*plaxes/2;
cpoints(:,4) = ncent - csize(1)*plfront/2 + csize(3)*plaxes/2;

% the relative positions
delta_max1 = max(ppoints(1,:)) - max(cpoints(1,:));
delta_min1 = - min(ppoints(1,:)) + min(cpoints(1,:));
delta_max2 = max(ppoints(3,:)) - max(cpoints(3,:));
delta_min2 = - min(ppoints(3,:)) + min(cpoints(3,:));

% class info
classindex = 0;
offsets = [0,0];
if(delta_min1<=delta_max1)
    classindex = classindex + 1;
    offsets(1) = delta_min1;
else
    offsets(1) = delta_max1;
end
if(delta_min2<delta_max2)
    classindex = classindex + 2;
    offsets(2) = delta_min2;
else
    offsets(2) = delta_max2;
end

% alignment info
attachindex = 0;
attacheps = 0.002;
if(abs(offsets(1))<attacheps)
    attachindex = attachindex + 1;
end
if(abs(offsets(2))<attacheps)
    attachindex = attachindex + 2;
end

% form the relpos vector
classvec = zeros(4,1);
classvec(classindex+1) = 1;
attachvec = zeros(4,1);
attachvec(attachindex+1) = 1;
rot_eps = 0.01;
rotation = nfront(1);
if(abs(abs(rotation)-1)<rot_eps|abs(rotation)<rot_eps)
    alignment = 1;
else
    alignment = 0;
end
relpos = [rotation;csize(1);csize(3);offsets(1);offsets(2);classvec;attachvec;alignment];

end

