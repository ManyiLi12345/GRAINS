function [ rp ] = adjustRelposBetweenWallFloor( rp, axis, classinfo, attachinfo )
%ADJUSTRELPOSBETWEENWALLFLOOR Summary of this function goes here
%   Detailed explanation goes here
classvec = rp(4:19);
[~,classindex] = max(classvec);
classxindex = mod(classindex,4);
if(classxindex==0)
    classxindex=4;
end
classyindex = floor((classindex-1)/4)+1;

if(axis==0)% x axis
    classxindex = classinfo;
else
    %y axis
    classyindex = classinfo;
end
classindex = classxindex + (classyindex-1)*4;
classvec = zeros(16,1);
classvec(classindex) = 1;
rp(4:19) = classvec;

attachvec = rp(20:23);
[~,attachindex] = max(attachvec);
attachxindex = mod(attachindex-1,2);
attachyindex = floor((attachindex-1)/2);
if(axis==0)% x axis
    attachxindex = attachinfo;
else
    %y axis
    attachyindex = attachinfo;
end
attachindex = 1;
if(attachxindex)
    attachindex = attachindex + 1;
end
if(attachyindex)
    attachindex = attachindex + 2;
end
attachvec = zeros(4,1);
attachvec(attachindex) = 1;
rp(20:23) = attachvec;

% rp(1) = angle;
% alignment = zeros(5,1);
% alignment(alignindex) = 1;
% rp(24:end) = alignment;

end

