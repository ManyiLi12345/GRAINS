clear;clc;
util;
VAEdata = load([data_folder, filesep, data_filename]);% load the generated data

tic
dataset = {};
for i = 1:length(VAEdata.boxes)
    data.leafreps = VAEdata.boxes{i}';
    data.relposreps = VAEdata.rplist{i}';
    data.kids = VAEdata.kids{i};
    [ ndata ] = convertPytorchData( data );
    ndata = adjustReconOffset( ndata );%adjust the one-hot vectors
    dataset{length(dataset)+1} = ndata;
end

rdataset = {};
for i = 1:length(dataset)
    fprintf([num2str(i),'\n']);
    p_data = dataset{i};

    % adjust the relpos between floor and wallnodes
    rplist = p_data.relposreps{length(p_data.relposreps)};
    rplist(1,:) = [-1,0.5,0.5,0.5];
    rplist(24:end,1:4) = 0;
    rplist(25,1) = 1;
    rplist(28,2:end) = 1;
    p_data.relposreps{length(p_data.relposreps)} = rplist;
	try
        [ rdata ] = reconOffset2Scene( p_data, 7, 6 , i, labelset_filename, objperlabel_filename, objfolder_path);
        [ rdata ] = optimize3dScene( rdata ); % generate 3D scenes from 2D

        % plot and save the topviews
        plotRoom2(rdata.obblist, rdata.labellist, 0);
        set(gcf,'position',[100 100 900 900])
        saveas(gcf, [output_img_folder, filesep,num2str(i),'.jpg']);
        close gcf;
catch
end
    % save the object meshes in the scenes
    scene_folder = [output_obj_folder, filesep, 'scene-', num2str(i)];
    mkdir(scene_folder);
    recon3dscene( rdata, scene_folder, 7, objfolder_path);
    rdataset{i} = rdata;
end
toc