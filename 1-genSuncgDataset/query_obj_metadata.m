function [ roomlist ] = query_obj_metadata( roomlist, scenename )
%QUERY_OBJ_METADATA 

if(exist(['..',filesep,'0-data',filesep,'ModelCategoryMapping.mat']))
    load(['..',filesep,'0-data',filesep,'ModelCategoryMapping.mat']);
else
	readModelCategoryMapping( 'ModelCategoryMapping_new.csv' );
    load(['..',filesep,'0-data',filesep,'ModelCategoryMapping.mat']);
end

if(exist(['..',filesep,'0-data',filesep,'Models.mat']))
    load(['..',filesep,'0-data',filesep,'Models.mat']);
else
    readModelOri( 'models.csv' );
    load(['..',filesep,'0-data',filesep,'Models.mat']);
end


for j = 1:length(roomlist)
	room = roomlist{j};

	objlist = room.objlist;
	labellist = {};
	for k = 1:length(objlist)
        obj = objlist{k};
        % query the front vector by id
        id = obj.modelId;
        mo = Models(id);
        obj.front = mo.front;
        obj.up = [0,1,0];
        bbox.min = mo.minPoint;
        bbox.max = mo.maxPoint;
        obj.localbbox = bbox;
        index = mo.index;
        % query the label by index
        label = ModelCategoryMapping(index);
        obj.label = label.grains_class;
        objlist{k} = obj;
        labellist{k} = obj.label;
    end
	room.objlist = objlist;
	room.scenename = scenename;
	room.roomname = [room.type, '#', room.id];
  	room.labellist = labellist;
	roomlist{j} = room;
end

end

