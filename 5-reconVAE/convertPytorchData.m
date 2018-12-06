function [ ndata ] = convertPytorchData( data )
%CONVERTPYTORCHDATA convert the pytorch data into offset format

kids = {};
nleafreps = [];
nrelposreps = [];
boxcount = 1;
rpcount = 1;
for i = 1:size(data.kids,1)
    k = data.kids(i,:);
    flag = k(1);
    switch(flag)
        case 0
            nleafreps(:,size(nleafreps,2)+1) = data.leafreps(:,boxcount);
            boxcount = boxcount + 1;
            nrelposreps{i} = [];
            kids{i} = 0;
        case 1
            rp = data.relposreps(:,rpcount);
            rpcount = rpcount+1;
            nrelposreps{i} = rp;
            kids{i} = k(1:3);
        case 2
            rp = data.relposreps(:,rpcount);
            rpcount = rpcount +1;
            nrelposreps{i} = rp;
            kids{i} = k(1:3);
        case 3
            rp = data.relposreps(:,rpcount);
            rpcount = rpcount +1;
            rplist = rp;
            rp = data.relposreps(:,rpcount);
            rpcount = rpcount + 1;
            rplist = [rplist,rp];
            nrelposreps{i} = rplist;
            kids{i} = k(1:4);
        case 4
            rp = data.relposreps(:,rpcount);
            rpcount = rpcount +1;
            rplist = rp;
            rp = data.relposreps(:,rpcount);
            rpcount = rpcount + 1;
            rplist = [rplist,rp];
            rp = data.relposreps(:,rpcount);
            rpcount = rpcount + 1;
            rplist = [rplist,rp];
            rp = data.relposreps(:,rpcount);
            rpcount = rpcount + 1;
            rplist = [rplist,rp];
            nrelposreps{i} = rplist;
          
            kids{i} = k(1:6);
        case 5
            rp = data.relposreps(:,rpcount);
            rpcount = rpcount+1;
            nrelposreps{i} = rp;
            kids{i} = k(1:3);
    end
            
end

leafreps = nleafreps;
relposreps = nrelposreps;

 map = zeros(1,length(kids));
 nodecount = length(kids);
 leafcount = size(data.leafreps,2);
 for i = 1:length(kids)
     k = kids{i};
     if(k(1)==0)
         % leaf
         map(i) = leafcount;
         leafcount = leafcount-1;
     else
         % internal
         map(i) = nodecount;
         nodecount = nodecount-1;
     end
 end
 nkids = cell(1,length(kids));
 nrelposreps = cell(1,length(relposreps));
 for i = 1:length(kids)
     nodeidx = map(i);
     k = kids{i};
     nk = [];
     flag = k(1);
     nlist = [];
     if(k(1)>0)
         list  = k(2:end);
         nlist = map(list);
     end
     nk = [flag;nlist(:)];
     nkids{nodeidx} = nk;
     nrelposreps{nodeidx} = relposreps{i};
 end
 
 ndata.kids = nkids;
 ndata.relposreps = nrelposreps;
 ndata.leafreps = fliplr(leafreps);

end

