function [ remove ] = selectHierarchies( data, NODETYPES )

%% select the hierarchies which meet our requirement

labellist = data.labellist;
kids = data.kids;
remove = 0;

% there should be one floor
ind = strmatch('floor',labellist,'exact');
if(length(ind)~=1)
    remove = 1;
    fprintf('don not have a floor\n');
end

% there should be one bed
%ind = strmatch('bed',labellist,'exact');
%if(length(ind)~=1)
%    remove = 1;
%    fprintf("don't have one bed\n");
%end

% the number of objects should be between 2~10, 8~15 including the walls
objnum = length(labellist);
%if(objnum<14||objnum>34)
if(objnum<8||objnum>15)
    remove = 1;
    fprintf('obj num:%d\n', objnum);
end

% check kids
for i = 1:length(kids)
    k = kids{i};
    if(length(k)>0)
        flag = k(1);
        if(flag~=0&&flag~=NODETYPES.COOCCUR&&flag~=NODETYPES.SUPPORT&&flag~=NODETYPES.SURROUND&&flag~=NODETYPES.ROOM&&flag~=NODETYPES.WALL)
            remove = 1;
            fprintf('node type error\n', objnum);
        end
        if(flag==NODETYPES.COOCCUR||flag==NODETYPES.SUPPORT||flag==NODETYPES.WALL)
            if(length(k)~=3)
                remove = 1;
                fprintf('group/support node error\n', objnum);
            end
        end
        if(flag==NODETYPES.SURROUND)
            if(length(k)~=4)
                remove = 1;
                fprintf('surround node error\n', objnum);
            end
        end
        if(flag==NODETYPES.ROOM)
            if(length(k)~=6)
                remove = 1;
                fprintf('room node error\n', objnum);
            end
        end
    else
        remove = 1;
    end
end

% set the max room size
MAXROOMSIZE = 7;
obblist = data.obblist;
for i = 1:size(obblist,2)
    cent = obblist(1:3,i);
    sizes = obblist(10:12,i);
    ind = find(abs(cent)>MAXROOMSIZE);
    ind2 = find(abs(sizes)>MAXROOMSIZE);
    if(length(ind)>0||length(ind2)>0)
        remove = 1;
        fprintf('exceed maxroom size\n', objnum);
    end
end

end

