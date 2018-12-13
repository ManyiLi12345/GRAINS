# Build the hierarchies 
This folder is the code to load the rooms with their relation graphs, and output the rooms represented as hierarchies.

## Note:
1. The objects not supported by the floor or other objects, are removed from the rooms.
2. The walls are arraged in a clock-wise order.
3. The surround relations involving walls or floors are removed.
4. The output hierarchies should satisfy the conditions in `selectHierarchies.m`, for example: floornum, objnum, maxroomsize, etc.

## Functions:
1. build the hierarchies for the scenes
```
run main_buildhierarchies.m
```	
It outputs a dataset which is a list of the generated hierarchies. 
The output is saved in folder `./0-data/2-hierarchies/`.

2. hierarchy visualization
For each element `data` in the generated dataset variable, use
```matlab
printtree2( data.kids, data.labellist, NODETYPES, <filename>)
```