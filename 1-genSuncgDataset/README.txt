This folder is the code to load the rooms and extract the relation graphs. 
It outputs the list of rectangular rooms wtih the specified room type from SUNCG dataset. 
The objects, which don't belong to one of the specified labelset, are removed from the rooms.

Note:
The objects are defined in column "grains_class" of ModelCategoryMapping_new.csv. The labelsets should be defined accordingly.

Functions:

1. scene graph generation
run main_gendata.m.
Output: dataset, which is a list of rooms. It will be saved in folder <code_dir>\0-data\1-graphs\<filename>
The printed info is:
[index of the new generated room data, scenename, roomname]

2. graph visulization
To visualize the relation graph of each room, use print_relations.m:
print_relations( dataset{i}, <filename>, RELATIONS );
It will print the graph code into the file, which can be visualized by graphviz tool.

3. scene visualization
to visualize the scene represented as variable "room":
addpath(genpath('..\vistools'));
plotRoom2(room.obblist, room.labellist, 0);