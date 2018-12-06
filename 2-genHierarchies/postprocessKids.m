function [ data, done ] = postprocessKids( data )

obblist = data.obblist;
labellist = data.labellist;
kids = data.kids;
ntypelist = data.ntypelist;
objnum = length(labellist);

% nkids = {};
nlabellist = {};
preservedobj = [];
nobblist = [];
done = 0;

%% select the subtree from floor's parent
ind = strmatch('floor',labellist,'exact');
if(length(ind)>0)
    floorind = ind(1);
    rootid = 0;
    for i = 1:length(kids)
        k = kids{i};
        ind = find(k==floorind);
        if(length(ind)>0)
            rootid = i;
            break;
        end
    end
    
    if(rootid>0)
        nmap = zeros(length(kids),1); % record the new indexin nkids of nodes in kids
        nodelist = {};
        nodelist{1,1} = kids{rootid};
        nodelist{1,2} = rootid;
        nkids = {};
        nleaves = {};
        while(length(nodelist)>0)
            node = nodelist{1,1};
            nodeoriid = nodelist{1,2};
            
            if(nodeoriid<=objnum)
                nleaves{length(nleaves)+1} = [ntypelist(nodeoriid),node];
                nmap(nodeoriid) = length(nleaves);
            else
                nkids{length(nkids)+1} = [ntypelist(nodeoriid),node];
                nmap(nodeoriid) = length(nkids);
            end
        
            k = kids{nodeoriid};
            for i = 1:length(k)
                nodelist{size(nodelist,1)+1,1} = kids{k(i)};
                nodelist{size(nodelist,1),2} = k(i);
            end
        
            nodelist = nodelist(2:end,:);
        
        end
    
        %% remove the unsupported objects and reorder the nodes
        nnkids = {};
        for i = length(nleaves):-1:1
            k = nleaves{i};
            nnkids{length(nnkids)+1} = k;
        end
        for i = length(nkids):-1:1
            k = nkids{i};
            for j = 2:length(k)
                ind = k(j);
                if(ind<=objnum)
                    label = labellist{ind};
                    nlabellist{length(nlabellist)+1} = label;
                    preservedobj = [preservedobj;ind];
                    nobblist = [nobblist,obblist(:,ind)];
                    k(j) = length(nlabellist);%length(nleaves)+1-nmap(ind);
                else
                    k(j) = length(nkids)+length(nleaves)+1-nmap(ind);
                end
                
            end
            nnkids{length(nnkids)+1} = k;
        end
    
        done = 1;
        data.kids = nnkids;
        data.labellist = labellist(preservedobj);
        data.Rmat = data.Rmat(preservedobj,preservedobj);
        data.Dmat = data.Dmat(preservedobj,preservedobj);
        data.obblist = nobblist;
%         data.layers = data.layers(preservedobj);
    end
end

end

