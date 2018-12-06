function drawDataset( dataset, dim )
% draw the scenes in the dataset and save the images in folder "images"
% load('embedding_labelset.mat');
labelset = {'bed', 'stand', 'lamp', 'rug', 'ottoman', 'person', 'floor'};
LABELLEN = length(labelset);
labeldefs = zeros(LABELLEN,LABELLEN);
for i = 1:LABELLEN
    labeldefs(i,i) = 1;
end
for i = 1:length(dataset)
    data = dataset{i};
    [ obblist, labellist ] = visualizeRelpos3( data.kids, data.mergereps, data.leafreps, labeldefs, labelset, dim );
    plotRoom2(obblist, labellist, 0);
    set(gcf,'position',[100 100 900 900])
    saveas(gcf, ['images',filesep,num2str(i),'.jpg']);
    close gcf;
end

end

