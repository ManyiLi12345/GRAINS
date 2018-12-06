%% this is to collect the distribution of relpos for an object pair
%% each room(element) of variable 'dataset' should have the obblist and labellist

label1 = 'desk';
label2 = 'chair';
outputfilename = [label2,'_',label1,'.jpg'];
addpath('../vistools');
poslist1 = [];
sizelist1 = [];
poslist2 = [];
for i = 1:length(dataset)
    data = dataset{i};
    idlist1 = strmatch(label1,data.labellist,'exact');
    idlist2 = strmatch(label2,data.labellist,'exact');
    if(length(idlist1)>0&length(idlist2)>0)
        for j = 1:length(idlist1)
            tobb = data.obblist(:,idlist1(j));
            cobblist = data.obblist(:,idlist2);
            tcent = tobb(1:3);
            ccentlist = cobblist(1:3,:);
            len = ccentlist - repmat(tcent,1,size(ccentlist,2));
            len = len.^2;
            len = len(1,:)+len(2,:)+len(3,:);
            [~,I] = min(len);
            cid = idlist2(I);
            cobb = data.obblist(:,cid);
            
            % compute the relative position
            pcent = tobb(1:3);
            pfront = tobb(4:6);
            pup = tobb(7:9);
            psize = tobb(10:12);
            ccent = cobb(1:3);
            cfront = cobb(4:6);
            cup = cobb(7:9);
            csize = cobb(10:12);
            transform = genTransMat(pfront,pup);
            ncent = ccent-pcent;
            ncent = transform*ncent; % child's center position in parent's local frame
            plcent = [0;0;0];
            poslist1 = [poslist1,plcent];
            sizelist1 = [sizelist1, psize];
            poslist2 = [poslist2,ncent];
        end
    end
end

figure;
scatter(poslist2(3,:),-poslist2(1,:),500,'b.');
hold on
for i = 1:size(sizelist1,2)
    sizevec = sizelist1(:,i);
    p1 = [-sizevec(1)/2,-sizevec(3)/2];
    p2 = [-sizevec(1)/2,sizevec(3)/2];
    p3 = [sizevec(1)/2,sizevec(3)/2];
    p4 = [sizevec(1)/2,-sizevec(3)/2];
    plot([p1(2),p2(2)],[p1(1),p2(1)],'color',[1,0,0]);
    plot([p2(2),p3(2)],[p2(1),p3(1)],'color',[1,0,0]);
    plot([p3(2),p4(2)],[p3(1),p4(1)],'color',[1,0,0]);
    plot([p4(2),p1(2)],[p4(1),p1(1)],'color',[1,0,0]);
    scatter(poslist2(3,i),-poslist2(1,i),500,'b.');
%     poslist2(1,i) = poslist2(1,i)/sizevec(1);
%     poslist2(3,i) = poslist2(3,i)/sizevec(3);
end

msize1 = max(sizelist1(1,:));
msize2 = max(sizelist1(3,:));
axis([-msize2,msize2,-msize1,msize1]);
title([label2,' positions against ',label1]);
saveas(gcf, outputfilename);