function drawRecon( inputset, reconsetlist )

%% reconsetlist
recontitles = {'obj-obj transform'};
% recontitles = {'absolute','obj-obj offset','obj-obj transform','parent-child relative pos'};
imgnum = 1+length(reconsetlist);
rownum = floor(sqrt(imgnum));
colnum = ceil(imgnum/rownum);
width = 1/colnum;
height = 1/rownum;

for i = 1:length(inputset)
    data = inputset{i};
    subplot(rownum,colnum,1);
    subplot('position',[(0)*width,(rownum-1)*height,width,height]);
    plotRoom2(data.obblist,data.nlabellist,0);
    title('input');
    
    for j = 1:length(reconsetlist)
        reconset = reconsetlist{j};
        recondata = reconset{i};
        num = j+1;
        rowid = ceil(num/colnum) ;
        colid = num - (rowid-1)*colnum ;
        subplot(rownum,colnum,1+j);
        subplot('position',[(colid-1)*width,(rownum-rowid)*height,width,height]);
        plotRoom2(recondata.obblist,recondata.nlabellist,0);
        title(recontitles{j});
    end
    
    set(gcf,'position',[100 100 900 900])
    saveas(gcf, ['images',filesep,num2str(i),'.jpg']);
    close gcf;
end

end

