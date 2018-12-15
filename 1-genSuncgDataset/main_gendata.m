clear;clc;
util;
addpath(genpath('jsonlab-master'));
dataset = {};

%% pre-defined paramters
walllabel = 'wall';
floorlabel = 'floor';

%% load the scene list
scenedir = dir(house_folder);
for i = 3:length(scenedir)
    scenelist{i-2} = scenedir(i).name;
end

%% binary label vectors
labelset = load(labelsetname); % 'entirelabelset.mat' is a list of all fine-grained labels
labelset = labelset.labelset;

%% process each scene(house)
for i = 1:length(scenelist)
    scenename = scenelist{i};
    filename = [house_folder, filesep, scenename];
    filename = [filename, filesep, 'house.json'];
    % load the scene as a list of rooms
    try
        roomlist = parsehouse(filename); 
        [ roomlist ] = query_obj_metadata( roomlist, scenename ); % fill in the object info (label, orientation, etc)
    catch
        fprintf([scenename,': ERROR in parsing house.json!\n']);
        continue;
    end

    for j = 1:length(roomlist)
        room = roomlist{j};
        roomname = room.roomname;
        try
            % only preserve the rooms meet our requirements
            [ iscontinue, floorobb, wallobblist, wallnum ] = selectroom( room, wcf_folder, roomtype );
            if(iscontinue)
                % transform the objects into [obb+label] format vector
                % and remove the objects with labels not in labelset
                room = convert_room_rep(room,labelset);
                
                % add wall objects to the room
                wallidx = strmatch(walllabel,labelset,'exact');
                wallonehot = zeros(length(labelset),1);
                wallonehot(wallidx) = 1;
                for v = 1:size(wallobblist,2)
                    room.labellist{length(room.labellist)+1} = walllabel;
                    room.obblist(1:size(room.obblist,1),size(room.obblist,2)+1) = [wallobblist(:,v);wallonehot];
                end
                
                % add floor to the room
                room.labellist{length(room.labellist)+1} = floorlabel;
                flooridx = strmatch(floorlabel,labelset,'exact');
                flooronehot = zeros(length(labelset),1);
                flooronehot(flooridx) = 1;
                room.obblist(1:size(room.obblist,1),size(room.obblist,2)+1) = [floorobb(:);flooronehot];
                
                % align the rooms, the floor is located at [0,0,0]
                room = alignroom( room );

                % extract the object-object relations, and relative
                % distance between objects
                [ Rmat, Dmat, sur ] = build_relationgraph( room.obblist', RELATIONS, length(labelset) );
                
                % add room to the dataset 
                room.Rmat = Rmat;
                room.Dmat = Dmat;
                room.sur = sur;
                dataset{length(dataset)+1} = room;
                
                fprintf([num2str(length(dataset)), ':', scenename,', ',roomname, '\n']);
            end
        catch
            fprintf([scenename,',', roomname,': ERROR in parsing organizing room! \n']);
            continue;
        end
    end

end
save(output_filename, 'dataset');


