function [ iscontinue, floorobb, wallobblist, wallnum ] = selectroom( room, wcf_folder, roomtype )
%SELECTROOM

iscontinue = 1;

%% correct room type
isroomtype = 0;
if(isfield(room,'roomTypes'))
	for k = 1:length(room.roomTypes)
        if(strcmp(roomtype,room.roomTypes{k}))
            isroomtype = 1;
            break;
        end
	end
end
if(~isroomtype)
    iscontinue = 0;
end
            
%% has at least one object
furnum = length(room.objlist);
if(furnum==0)
    % only unempty rooms
    iscontinue = 0;
end
            
%% has one floor and four walls
wcf_filename = [wcf_folder, filesep, room.scenename, filesep, room.roomname,'.mat'];
floornum = 0;
floorobb = [];
wallobblist = [];
wallnum = 0;
if(exist(wcf_filename,'file'))
	wcf = load(wcf_filename);
	floorid = strmatch('Floor',wcf.label_list);
	floornum = length(floorid);
    wallidx = strmatch('Wall',wcf.label_list);
	wallnum = length(wallidx);
end
if(floornum==1&&wallnum==8)
    % only keep rectangle rooms with one floor
	floorobb = wcf.obb_list(:,floorid);
    if(length(floorobb)<12)
        floorobb1 = [floorobb(1:3);1;0;0;floorobb(4:9)];
        floorobb = floorobb1;
    end
    wallindex = 1:2:7;
    wallindex = wallidx(wallindex);
    wallobblist = wcf.obb_list(:,wallindex);
    wallobblist = [wallobblist(1:6,:);repmat(floorobb(7:9),1,size(wallobblist,2));wallobblist(7:9,:)];
%     midpoint = sum(wallobblist(1:3,:)')/size(wallobblist,2);
%     for j = 1:size(wallobblist,2)
%         obb = wallobblist(:,j);
%         front = midpoint-obb(1:3)';
%         front = front/norm(front,2);
%         obb = [obb(1:3);front';obb(4:9)];
%         wallobblist1(:,j) = obb;
%     end
%     wallobblist = wallobblist1;
else
    iscontinue = 0;
end


end

