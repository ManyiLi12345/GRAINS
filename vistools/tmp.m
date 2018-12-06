% two dataset: dataset, dataset_prelpos

for i = 1:length(dataset)
    data = dataset{i};
    pdata = dataset_prelpos{i};
    
    subplot(1,2,1);
    subplot('position',[0,0,0.45,0.9]);
    obblist = data.obblist;
    labellist = data.labellist;
    plotRoom2(obblist,labellist,0);
    title('oritinal room');
    
    subplot(1,2,2);
    subplot('position',[0.5,0,0.45,0.9]);
%     [ obblist, labellist ] = visualizeReltransform( pdata.leafreps, labeldefs, labelset, 2 );
    [ obblist, labellist ] = visualizeRelpos3( pdata.kids, pdata.mergereps, pdata.leafreps, labeldefs, labelset, 2 );
    plotRoom2(obblist,labellist,0);
    title('prelpos format');
    
    set(gcf,'position',[100 100 900 900])
    saveas(gcf, ['images',filesep,num2str(i),'.jpg']);
    close gcf;
end