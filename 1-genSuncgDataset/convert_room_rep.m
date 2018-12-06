function [ room ] = convert_room_rep( room, labelset )

% convert the objects of each room to the [obb+label] format
% INPUT: room - the room extract from .json file
%        labelset - the considered label set. Labels in this set use
%        one-hot vector, others use zero vectors
% OUTPUT: the room with updated obblist, labellist, objlist

obblist = [];
objlist = room.objlist;
for i = 1:length(objlist)
    obj = objlist{i};

    % local directions
    lup = obj.up;
    lfront = obj.front;
    laxis = cross(lup,lfront);
    laxis = laxis/norm(laxis,2);
    localbbox = obj.localbbox;
    
    transform = reshape(obj.transform,4,4);
    for j = 1:3
        transform(1:3,j) = transform(1:3,j)/norm(transform(1:3,j),2);
    end
    
    % local and global max&min coordinates
    globbox = obj.bbox;
    scale = norm(globbox.max - globbox.min,2)/norm(localbbox.max-localbbox.min,2);
    lminp = localbbox.min;
    lmaxp = localbbox.max;
    ldia = lmaxp - lminp;
    gminp = globbox.min;
    gmaxp = globbox.max;

    % compute the global directions
    gfront = transform*[lfront(:);0];
    gfront = gfront(1:3);
    gfront = gfront/norm(gfront,2);
    gup = transform*[lup(:);0];
    gup = gup(1:3);
    gup = gup/norm(gup,2);
    gaxis = cross(gup,gfront);
    gaxis = gaxis/norm(gaxis,2);
    
    % compute the sizes along local axes
    fsize = abs(ldia*lfront(:))*scale;
    usize = abs(ldia*lup(:))*scale;
    asize = abs(ldia*laxis(:))*scale;
    cent = (gmaxp+gminp)/2;
    
    % label vector
    label = zeros(length(labelset),1);
    ind = strmatch(obj.label,labelset,'exact');
    if(length(ind)>0)
        label(ind)=1;
    end
 
    vec = [cent(:);gfront(:);gup(:);fsize;usize;asize;label(:)];   
    obblist(:,i) = vec;
end

iskept = sum(obblist(end-length(labelset)+1:end,:));
ind = find(iskept>0);
room.obblist = obblist(:,ind);
room.objlist = objlist(ind);
room.labellist = room.labellist(ind);

end

