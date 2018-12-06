for i = 1:length(dataset)
    data = dataset{i};
    mat = plotRoom3(data.obblist,data.labellist,0);
    
    B = imresize(mat,[224,224]);
    imwrite(B,['images',filesep,num2str(i),'.png']);
%     saveas(gcf, ['images',filesep,num2str(i),'.png']);
    close gcf
end