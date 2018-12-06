%GENSUNCGDATASET generate the offset format for suncg dataset
clear;clc;
util;
load(data_filename);
preprocess;
addpath(genpath('..\vistools'));
load(labelsetname);

ndataset = {};
rdataset = {};
for i = 1:length(dataset)
    data = dataset{i};
    
    ndata = genOffsetRep( data, labelset );
    rplist = ndata.relposreps{length(ndata.relposreps)};
    for j = 1:length(ndata.relposreps)
        rplist = ndata.relposreps{j};
    end
    ind = find(rplist(23,:)~=1);
    ndataset{length(ndataset)+1} = ndata;
    
%% recon the data to validate
%     rdata = readOffsetRep_v2( ndata, labelset, 0, i );
%     rdataset{length(rdataset)+1} = rdata;
%     
%     subplot(1,2,1);
% 	subplot('position',[0,0,0.45,0.9]);
%     plotRoom2(data.obblist,data.labellist,0);
%     title('original room');
%     
% 	subplot(1,2,2);
% 	subplot('position',[0.5,0,0.45,0.9]);
%     plotRoom2(rdata.obblist,rdata.labellist,0);
%     title('reconstruction');
% 	set(gcf,'position',[100 100 900 900])
    
%     saveas(gcf, ['images',filesep,num2str(i),'.jpg']);
%     close gcf
end
dataset = ndataset;
save(output_filename, 'dataset');

