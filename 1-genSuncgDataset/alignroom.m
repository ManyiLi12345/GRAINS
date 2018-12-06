function [ room ] = alignroom( room )

% align the room to [0,0,0]
% if there's a floor and is the last object in the list, then move the
% floor center to [0,0,0]
% if there's not a floor, move based on other object centers

obblist = room.obblist;
if(strcmp('floor',room.labellist{length(room.labellist)}))
    floorobb = obblist(:,size(obblist,2));
    trans_pos = floorobb(1:3);
    if(size(obblist,2)>0)
        obblist(1:3,:) = obblist(1:3,:)-repmat(trans_pos(:),1,size(obblist,2));
    end
    room.obblist = obblist;
else
    if(size(obblist,2)>1)
        % if there's not a floor
        pos = obblist(1:3,:);
        max_pos = max(pos');
        min_pos = min(pos');
        trans_pos = (max_pos+min_pos)/2;
        trans_pos(1,2) = min_pos(2);
    end
    if(size(obblist,2)==1)
        pos = obblist(1:3);
        trans_pos = pos;
    end
    if(size(obblist,2)>0)
        obblist(1:3,:) = obblist(1:3,:)-repmat(trans_pos(:),1,size(obblist,2));
    end
    room.obblist = obblist;
end


end

