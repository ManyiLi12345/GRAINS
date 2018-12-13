data_folder = ['..', filesep, '0-data'];
labelset_folder = [data_folder, filesep, 'labelsets'];
house_folder = [data_folder, filesep, 'SUNCG', filesep, 'house'];
wcf_folder = [data_folder, filesep, 'SUNCG', filesep, 'room_wcf'];
output_folder = [data_folder, filesep, '1-graphs'];

RELATIONS.COOCCUR = 0;
RELATIONS.SUPPORT1 = -1;
RELATIONS.SUPPORT2 = -2;
RELATIONS.ATTACH = -3;
RELATIONS.SIDEBYSIDE = -4;
RELATIONS.SYMSUR_START = 10;

%% here to specify the room type
roomtype = 'Bedroom';
labelsetname = [labelset_folder, filesep, 'bedroomlabelset.mat']; 
output_filename = [output_folder, filesep, 'bedroom_graph.mat'];