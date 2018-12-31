# Prepare the training set
This folder contains the code to prepare the data for PyTorch training.

## Functions
Run
```
 main_genprelpos_pydata.m
```
It generates the training data with our relative position format. 
It outputs three files: `ops.mat`, `boxes.mat`, `relpos.mat`.
The files are saved in the folder `./0-data/4-pydata/`.
