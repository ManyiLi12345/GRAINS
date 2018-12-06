function [ rp ] = genRelpos( pobb,cobb )
%GENRELPOS generate the position of obb2 relative to obb1

pcent = pobb(1:3);
pfront = pobb(4:6);
pup = pobb(7:9);
% paxes = cross(pfront,pup);
% paxes = paxes/norm(paxes,2);

% pfront4 = [pfront;0];
% pup4 = [pup;0];
% paxes4 = [paxes;0];
% transform = [pfront4';pup4';paxes4];
% ap = [0,0,0,1];
% transform = [transform;ap];
transform = genTransMat(pfront,pup);

ncent = cobb(1:3)-pcent;
ncent = transform*ncent;

nfront = cobb(4:6);
nfront = transform*nfront;

nup = cobb(7:9);
nup = transform*nup;

rp = [ncent(:);nfront(:);nup(:)];



end

