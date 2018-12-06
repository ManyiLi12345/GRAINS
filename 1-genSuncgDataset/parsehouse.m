function [ roomlist ] = parsehouse( filename )

% parse the rooms and their objects from a house.json file
% INPUT: filename - the scene(house) name
% OUTPUT: roomlist - the rooms in this house. Each room has a "objlist" containing all the inside objects.
% all info in the house.json file is recorded in the nodes.

result = {};
house = loadjson(filename);
levellist = house.levels;

for i = 1:length(levellist)
    level = levellist{i};
    nodelist = level.nodes;

    % collect all the rooms
    roomlist = {};
    for j = 1:length(nodelist)
        node = nodelist{j};
        if(strcmp('Room',node.type))
            roomlist{length(roomlist)+1} = node;
        end
    end

    % collect the objects for each room
    for j = 1:length(roomlist)
        room = roomlist{j};
        objlist = {};
        if(isfield(room,'nodeIndices'))
            nodeIndices = room.nodeIndices+1;
            for k = 1:length(nodeIndices)
                node = nodelist{nodeIndices(k)};
                if(strcmp('Object',node.type))
                    objlist{length(objlist)+1} = node;
                end
            end
        end
        room.objlist = objlist;
        roomlist{j} = room;
    end

    result = cat(2,result, roomlist);
end

end

