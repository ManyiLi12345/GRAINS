function [ rp ] = genRelpos1( pobb,cobb )
%GENRELPOS generate the position of obb2 relative to obb1

pcent = pobb(1:3);
pfront = pobb(4:6);
pup = pobb(7:9);
psize = pobb(10:12);
paxes = cross(pfront,pup);
paxes = paxes/norm(paxes,2);

ccent = cobb(1:3);
cfront = cobb(4:6);
cup = cobb(7:9);
csize = cobb(10:12);
caxes = cross(cfront,cup);
caxes = caxes/norm(caxes,2);

ncsize = csize(1)*cfront + csize(2)*cup + csize(3)*caxes;
fcsize = ncsize'*pfront;
ucsize = ncsize'*pup;
acsize = ncsize'*paxes;

transform = genTransMat(pfront,pup);
ncent = ccent-pcent;
ncent = transform*ncent;
ncent = ncent - psize;
ncent = ncent - [fcsize;ucsize;acsize];

nfront = cobb(4:6);
nfront = transform*nfront;

nup = cobb(7:9);
nup = transform*nup;

rp = [ncent(:);nfront(:);nup(:)];



end

