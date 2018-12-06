function [ recondata ] = adjustReconOffset( recondata )
%ADJUSTRECONOFFSET adjust the recondata, based on its reinforce info

relposreps = recondata.relposreps;

for i = 1:length(relposreps)
    rplist = relposreps{i};
    if(size(rplist,2)>0)
        for j = 1:size(rplist,2)
            rp = rplist(:,j);
            classvec = rp(4:19);
            [~,classindex] = max(classvec);
            classvec = zeros(16,1);
            classvec(classindex)=1;
            rp(4:19) = classvec;
            
            attachvec = rp(20:23);
            [~,attachindex] = max(attachvec);
            attachvec = zeros(4,1);
            attachvec(attachindex)=1;
            rp(20:23) = attachvec;
            if(mod(attachindex-1,2)==1)
                rp(2) = 0;
            end
            if(floor((attachindex-1)/2)==1)
                rp(3) = 0;
            end
            
            alignvec = rp(24:28);
            [~,alignindex] = max(alignvec);  
            alignvec = zeros(5,1);
            alignvec(alignindex) = 1;
            rp(24:28) = alignvec;
            rplist(:,j) = rp;
        end
    end
    relposreps{i} = rplist;
end

recondata.relposreps = relposreps;

end

