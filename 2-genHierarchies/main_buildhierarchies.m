clear;clc;
util;
addpath(genpath('..\vistools'));

% param setting
load(data_filename); % load the rooms with the relation graphs
load(labelsetname);
wallid_labelset = strmatch('wall',labelset,'exact');

% generate the hierarchies
ndataset = {};
%fdataset = {};
for i = 1:length(dataset)
    fprintf(['id:',num2str(i),'\n']);
    data = dataset{i};
    try
        % sort the walls based on counter-clockwise order
        % walls are supported by the floor
        % floor is not supported by any other object
        
        data = sortWalls_v2(data);
        
        % organize the hierarchies
        [kids, ntypelist] = roomhierarchy(data,RELATIONS, NODETYPES);
        data.kids = kids;
        data.ntypelist = ntypelist;
        [ data, done ] = postprocessKids( data );
        
        % select the hierarchies which satisfy the conditions
        [ remove ] = selectHierarchies( data, NODETYPES );
        
        % each internal node should have more than one child
        len = 0;
        for j = 1:length(kids)
            if(length(kids{j})>0)
                len = 1;
            end
        end
        if(len==0)
            remove = 1;
        end
    catch
        remove = 1;
		fprintf('error in building the hierarchy!\n');
    end
    
    if(remove==0)
    	ndataset{length(ndataset)+1} = data;
    end
    %fdataset{i} = data;
end
dataset = ndataset;
save(output_filename, 'dataset');