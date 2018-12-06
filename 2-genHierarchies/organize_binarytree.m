function [ kids, ntypelist ] = organize_binarytree( parent, distmat, objnum, NODETYPES, flooridx)
%ORGANIZESUBTREE 

ntypelist = parent(2,:);

kids = {};
for i = 1:size(parent,2)
    ind = find(parent(1,:)==i);
    kids{i} = ind;
end

%floorid = length(kids);

for i = 1:length(kids)
    k = kids{i};
    isobj = (i<=objnum);
    correctchildnum = 2-isobj;
    if(i==flooridx)
        correctchildnum = 5;
    end
    if(ntypelist(i)==NODETYPES.SURROUND)
        break;
    end
    % children number is more than 2-isobj
    while(length(k)>correctchildnum)
        
        % find the pair of closest children, with index ind_i and ind_j
        dist = distmat(k,k);
        for j = 1:size(dist,1)
            dist(j,j) = NaN;
        end
        [~,ind] = min(dist(:));
        ind_j = floor((ind-1)/size(dist,1))+1;
        ind_i = mod((ind-1),size(dist,1))+1;
        
        % merge the two children first, update the infos
        nk = [k(ind_i),k(ind_j)];
        kids{length(kids)+1} = nk;
        ntypelist = [ntypelist,NODETYPES.COOCCUR];
        
        % update the i'th children list
        ind = 1:length(k);
        ind = find(ind~=ind_i&ind~=ind_j);
        k = [k(ind),length(kids)];
        
        % update distmat
        dd = distmat(nk,:);
        if(size(dd,1)>1)
            dd = min(dd);
        end
        distmat = [distmat;dd];
        dd = [dd(:);0];
        distmat = [distmat,dd];
    end
    
    if(isobj&&length(k)>=1)
        % object node cannot be internal nodes
        % merge its child (only one) with itself
        p = 0;
        knum = 0;
        for j = 1:length(kids)
            nk = kids{j};
            ind = find(nk==i);
            if(length(ind)==1)
                p = j;
                knum = length(nk);
            end
        end
        pisobj = (j<=objnum);
        
        if(p>1&&length(kids{p})<2-pisobj)
            % if its parent can have one more child
            nk = kids{p};
            nk = [nk,k];
            kids{p} = nk;
            kids{i} = [];
        else
            
            nk = [i,k];
            kids{length(kids)+1} = nk;
            ntypelist = [ntypelist, ntypelist(i)];
            kids{i} = [];
        
            % update its parent info
            for j = 1:length(kids)-1
                ind = find(kids{j}==i);
                if(length(ind)>0)
                    tk = kids{j};
                    tk(ind) = length(kids);
                    kids{j} = tk;
                end
            end
        
            % update distmat
            dd = distmat(nk,:);
            if(size(dd,1)>1)
                dd = min(dd);
            end
            distmat = [distmat;dd];
            dd = [dd(:);0];
            distmat = [distmat,dd];
        end
    else
    	kids{i} = k;
    end
        
end

% floor_childlist = kids{floorid};
% kids{length(kids)+1} = [floorid,floor_childlist];
% ntypelist(length(kids)) = NODETYPES.SUPPORT;
% kids{floorid} = [];

%% merge the walls and floors at last
% lastmerge = kids{length(kids)};
% floorid = lastmerge(1);
% wallind = lastmerge(2:end);
% for i = 1:length(wallind)
%     k = kids{wallind(i)};
%     if(length(k)>1)
%         wallind(i) = k(2);
%     end
% end
% lastmerge = [floorid,wallind];
% kids{length(kids)} = lastmerge;

for i = 1:objnum
    ntypelist(i) = 0;
end

% nparent = zeros(length(kids),1);
% rootid = 0;
% for i = 1:length(kids)
%     k = kids{i};
%     nparent(k) = i;
%     ind = find(k==objnum); % objnum is the index of floor
%     if(length(ind)>0)
%         % root is the parent of floor
%         rootid = i;
%     end
% end


end

