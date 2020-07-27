# GRAINS: Generative Recursive Autoencoders for INdoor Scenes

This is the code for our paper "GRAINS: Generative Recursive Autoencoders for INdoor Scenes".<br/>
Project webpage [here](https://manyili12345.github.io/Publication/2018/GRAINS/index.html). 

##### Update: Because of the SUNCG dataset problem, we have removed the pretraned models and the room_wcf data file. Here we provide the [data format definition](https://github.com/ManyiLi12345/GRAINS/blob/master/data_format_definition.txt) for the room_wcf file used in our code and [a sample file](https://github.com/ManyiLi12345/GRAINS/blob/master/0-data/room_wcf_for_00a9efc8d6dcc489ea8f67b2fe486b03.zip) which can be visualized with [this script](https://github.com/ManyiLi12345/GRAINS/blob/master/vistools/vis_wcf.m). Please follow this format to create your own room_wcf file from other indoor scene dataset to use our code.

## Requirements
The code has been tested on the following. To re-run our code, we recommend the below softwares/tools to work with:<br />
(a) Python 2.7 and Pytorch 0.3.1, OR<br /> 
(b) Python 3.6/3.7 and Pytorch >1.0, and <br />
(c) MATLAB (>2017a)

## Environment setup
The best way is to install the latest Python and Pytorch versions is via Anaconda.
1) Download your version (depending on your OS) of anaconda from [here](https://www.anaconda.com/distribution/).
2) Make sure your conda is setup properly. This is how you do it: 
```
export PATH="............./anaconda3/bin:$PATH"
```
3) The following command at the terminal prompt should not throw any error 
```
conda
```
4) Create a virtual environment called "GRAINS". 
```
conda create --name GRAINS
```
5) Activate your virtual env: 
```
source activate GRAINS
```
You are now setup with the working environments.

## Cloning this repo
Make a local copy of this repository using
```
git clone https://github.com/ManyiLi12345/GRAINS.git
```

## Data preparation
There is an ongoing legal dispute with using the training dataset made use of in our work. Follow the below at your own risk.

We use indoor scenes represented as herarchies for the training. To create the training data, first download the [original Dataset](http://suncg.cs.princeton.edu/) and extract `house`, `object`, `room_wcf` folder under the path `./0-data/SUNCG/`.

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

# Citation
If you find this work useful for your research, please cite GRAINS using the bibtex below:

```
@article{li2019grains,
  title={Grains: Generative recursive autoencoders for indoor scenes},
  author={Li, Manyi and Patil, Akshay Gadi and Xu, Kai and Chaudhuri, Siddhartha and Khan, Owais and Shamir, Ariel and Tu, Changhe and     Chen, Baoquan and Cohen-Or, Daniel and Zhang, Hao},
  journal={ACM Transactions on Graphics (TOG)},
  volume={38},
  number={2},
  pages={12},
  year={2019},
  publisher={ACM}
}
```
