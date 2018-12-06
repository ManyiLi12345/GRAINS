This code is for paper: GRAINS: Generative Recursive Autoencoders for INdoor Scenes.

The pipeline is divided into 5 steps in different folders. Each step can be excuted independently.

Data preparation:
Extract "house", "object", "room_wcf" folder under the path "./0-data/SUNCG/"

Step1. Load indoor scenes from SUNCG dataset and extract the object relations
	run ./1-genSuncgDataset/main_gendata.m

Step2. Build the hierarchies for every indoor scenes
	run ./2-genHierarchies/main_buildhierarchies.m

Step3. Transform the data representation with relative positions
	run ./3-datapreparation/main_genSUNCGdataset.m

Step4. Prepare the training set and train/test the network
	run ./4-genPytorchData/main_genprelpos_pydata.m
	To train the network, run ./4-training/train.py
	To test the network, run ./4-training/test.py

Step5. Reconstruct the generated indoor scenes
	run ./5-reconVAE/main_recon.m

For the code of each step, the data path and other configurations are set in util.m(or util.py).
Each step has a README file for more details.