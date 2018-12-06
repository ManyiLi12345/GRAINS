function [ data ] = sortWalls( data )
%SORTWALLS re-order the walls based on their orientation
% and delete the surround relations with walls

wallind = strmatch('wall',data.labellist,'exact');
wallfront = data.obblist([4,6],wallind);
wallidx = 1:size(wallfront,2);

% 1st floor
delta = wallfront - repmat([1;0],1,size(wallfront,2));
delta = delta.*delta;
delta = delta(1,:)+delta(2,:);
[~,I] = min(delta);
fid1 = wallidx(I);
ind = find([1:size(wallfront,2)]~=I);
wallfront = wallfront(:,ind);
wallidx = wallidx(ind);
        
% 2st floor
delta = wallfront - repmat([0;1],1,size(wallfront,2));
delta = delta.*delta;
delta = delta(1,:)+delta(2,:);
[~,I] = min(delta);
fid2 = wallidx(I);
ind = find([1:size(wallfront,2)]~=I);
wallfront = wallfront(:,ind);
wallidx = wallidx(ind);
        
% 3st floor
delta = wallfront - repmat([-1;0],1,size(wallfront,2));
delta = delta.*delta;
delta = delta(1,:)+delta(2,:);
[~,I] = min(delta);
fid3 = wallidx(I);
ind = find([1:size(wallfront,2)]~=I);
wallfront = wallfront(:,ind);
wallidx = wallidx(ind);
        
% 4st floor
delta = wallfront - repmat([0;-1],1,size(wallfront,2));
delta = delta.*delta;
delta = delta(1,:)+delta(2,:);
[~,I] = min(delta);
fid4 = wallidx(I);
ind = find([1:size(wallfront,2)]~=I);
wallfront = wallfront(:,ind);
wallidx = wallidx(ind);

wallorder = [fid1,fid2,fid3,fid4];
walllist = data.obblist(:,wallind);
data.walllist = walllist(:,wallorder);
data.obblist(:,wallind) = walllist(:,wallorder);

% update the Rmat and Dmat
wallRmat = data.Rmat(:,wallind);
wallRmat = wallRmat(:,wallorder);
data.Rmat(:,wallind) = wallRmat;
data.Rmat(wallind,:) = wallRmat';

wallDmat = data.Dmat(:,wallind);
wallDmat = wallDmat(:,wallorder);
data.Dmat(:,wallind) = wallDmat;
data.Dmat(wallind,:) = wallDmat';
% 
% %% all the walls should be supported by the floor
% floorid = strmatch('floor',data.labellist,'exact');
% data.Rmat(wallind,floorid) = -2;
% data.Rmat(floorid,wallind) = -1;

%% delete the surround relations with walls
% nsur = {};
% for i = 1:length(data.sur)
%     list = data.sur{i};
%     ind = intersect(list,wallind);
%     if(length(ind)==0)
%         nsur{length(nsur)+1} = list;
%     end
% end
% data.sur = nsur;

%% floor is not supported by any object
% ind = find(data.Rmat(:,floorid)==-1|data.Rmat(:,floorid)==-3);
% data.Rmat(ind,floorid) = -2;
% data.Rmat(floorid,ind) = -1;


end

