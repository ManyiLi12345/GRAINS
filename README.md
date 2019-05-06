# GRAINS: Generative Recursive Autoencoders for INdoor Scenes

This is the code for our paper "GRAINS: Generative Recursive Autoencoders for INdoor Scenes".<br/>
Project website [here](https://manyili12345.github.io/Publication/2018/GRAINS/index.html). 

## Requirements
The code has been tested on the following. To re-run our code, we recommend the below softwares/tools to work with:<br />
(a) Windows 10, <br/>
(b) Python 2.7 and Pytorch 0.3.1,<br />
(c) Python 3.6 and Pytorch 1.0, and <br />
(d) MATLAB (>2017a)

## Data preparation
We use indoor scenes represented as herarchies for the training. To create the training data, first download the [original SUNCG Dataset](http://suncg.cs.princeton.edu/) and extract `house`, `object`, `room_wcf` folder under the path `./0-data/SUNCG/`.

The `room_wcf` data is [here](https://drive.google.com/open?id=1RPF6YJsNNanNCBBRGAfDcNtuzLimrNVA)

### Step1. Load indoor scenes from SUNCG dataset and extract the object relations
```
run ./1-genSuncgDataset/main_gendata.m
```
The output is saved in `./0-data/1-graphs`.

### Step2. Build the hierarchies for every indoor scenes
```
run ./2-genHierarchies/main_buildhierarchies.m
```
The output is saved in `./0-data/2-hierarchies`.

### Step3. Transform the data representation with relative positions
```
run ./3-datapreparation/main_genSUNCGdataset.m
```
The output is saved in `./0-data/3-offsetrep`.

### Step4. Prepare the training set
```
run ./4-genPytorchData/main_genprelpos_pydata.m
```
The output is saved in `./0-data/4-pydata`.

## Training and Inference
### Training
```
run ./4-training/train.py
```
It loads the training set from `./0-data/4-pydata`. The trained model will be saved in `./0-data/models/`. You can download the pre-trained model [here](xxxx).

### Inference
```
run ./4-training/test.py
```
It loads the trained model in `./0-data/models/` and randomly generate 1000 scenes. The output is a set of scenes represented as hierarchies, saved as `./0-data/4-pydata/generated_scenes.mat`.

## Reconstruct the generated indoor scenes
```
run ./5-reconVAE/main_recon.m
```
It reconstructs the object OBBs in each scene from the generated hierarchy. The topview images are saved in `./0-data/5-generated_scenes/images/`.

# Acknowledgement
The training part of our code is built upon [GRASS](https://github.com/kevin-kaixu/grass_pytorch).

# Ciatition
Please cite the paper if you use this code for research:

```
@article{li2018grains,
title={GRAINS: Generative Recursive Autoencoders for Indoor Scenes}, 
author={Li, Manyi and Gadi Patil, Akshay and Xu, Kai and Chaudhuri, Siddhartha and Khan, Owais and Shamir, Ariel and Tu, Changhe and Chen, Baoquan and Cohen-Or, Daniel and Zhang, Hao}, 
journal={ACM Transactions on Graphics}, 
volume={},
number={}, 
year={},
publisher={ACM}
}
```
