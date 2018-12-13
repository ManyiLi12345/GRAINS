# Generate the relation graphs for each scene
This part in the folder is the code to load the rooms and extract the relation graphs. 
It outputs the list of rectangular rooms with the specified room type from SUNCG dataset. 
The objects, which don't belong to one of the specified labelset, are removed from the rooms.

You can specify the `roomtype`, `labelsetname`, `output_filename` in the file `util.m`.

## Functions
```
run ./1-genSuncgDataset/main_gendata.m
```