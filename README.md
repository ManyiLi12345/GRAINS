# GRAINS: Generative Recursive Autoencoders for INdoor Scenes

This is the code for our paper "GRAINS: Generative Recursive Autoencoders for INdoor Scenes".

## Data preparation
We use indoor scenes represented as herarchies for the training. To create the training data, first donwload the [original SUNCG Dataset](http://suncg.cs.princeton.edu/) and extract 'house', 'object', 'room_wcf' folder under the path './0-data/SUNCG/'.

The "room_wcf" data is [here](https://drive.google.com/open?id=1RPF6YJsNNanNCBBRGAfDcNtuzLimrNVA)

### Step1. Load indoor scenes from SUNCG dataset and extract the object relations
	run ./1-genSuncgDataset/main_gendata.m


### Step2. Build the hierarchies for every indoor scenes
	run ./2-genHierarchies/main_buildhierarchies.m

### Step3. Transform the data representation with relative positions
	run ./3-datapreparation/main_genSUNCGdataset.m

### Step4. Prepare the training set and train/test the network
	run ./4-genPytorchData/main_genprelpos_pydata.m

## Training and Inference
	To train the network, run ./4-training/train.py
	To test the network, run ./4-training/test.py

Step5. Reconstruct the generated indoor scenes
	run ./5-reconVAE/main_recon.m

For the code of each step, the data path and other configurations are set in util.m(or util.py).
