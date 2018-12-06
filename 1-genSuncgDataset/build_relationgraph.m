function [ Rmat, Dmat, sur ] = build_relationgraph( obblist, RELATIONS, LABELLEN )

% Compute the object-object relation and relative distance
% INPUT: obblist - a list of objects in obb format
%        RELATIONS - predefined relation types
%        LABELLEN - length of label vector
%
% OUTPUT: Rmat - relation matrix
%         Dmat - relative distance matrix
%         sur - a cell array, each cell is a surround pair, with the first object as the central object

obbnum = size(obblist,1);
Rmat = zeros(obbnum,obbnum);
Dmat = zeros(obbnum,obbnum);

for i = 1:obbnum
    obb1 = obblist(i,:);
    for j = i+1:size(obblist,1)
       obb2 = obblist(j,:);
       % compute relation and relative distance of two obbs
       [R,D] = obbrelation(obb1, obb2, RELATIONS);
       Rmat(i,j) = R;
       Dmat(i,j) = D;
       Dmat(j,i) = D;
       switch(R)
           % support relation is a directed edge
           case RELATIONS.SUPPORT1
               Rmat(j,i) = RELATIONS.SUPPORT2;
           case RELATIONS.SUPPORT2
               Rmat(j,i) = RELATIONS.SUPPORT1;
           otherwise
               Rmat(j,i) = R;
       end

    end
end

% detect the surround relation
[ sur ] = detect_sym( obblist, Rmat, Dmat, RELATIONS, LABELLEN );


end

