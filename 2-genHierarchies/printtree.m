function printtree( kids, ntypelist,labellist, NODETYPES, filename )

fid = fopen(filename,'wt');
fprintf(fid, 'digraph G { \n');
fprintf(fid, '\t ratio = fill \n');
fprintf(fid, '\t node [style = filled] \n');

% corlist = {[1,0,0,0.3],[0,1,0,0.3],[0,1,1,0.3],[0,0,1,0.3],[1,0,1,0.3]};
corlist = {'red','green','cyan','blue','purple'};

%% print the nodes
for i = 1:length(kids)
    cor = corlist{mod(i-1,length(corlist))+1};
    namei = num2str(i);
    if(i<=length(labellist))
        namei = [labellist{i},namei];
    end
%     fprintf(fid, ['\t\"', namei, '\" [color = ', cor, ']; \n' ]);
    fprintf(fid, ['\t\"', namei, '\"; \n' ]);
end
fprintf(fid, '\n');

fprintf(fid, '\t subgraph suppG { \n');
for i = 1:length(kids)
    k = kids{i};
    for j = 1:length(k)
        pname = num2str(i);
        if(i>0&i<=length(labellist))
            pname = [labellist{i},pname];
        end
        
        cname = num2str(k(j));
        if(k(j)>0&k(j)<=length(labellist))
            cname = [labellist{k(j)},cname];
        end
        
            if(ntypelist(i)==NODETYPES.SUPPORT)
                fprintf(fid, ['\t\t\"', pname, '\" -> \"', cname, '\" [color = red]; \n' ]);
            end
            if(ntypelist(i)==NODETYPES.COOCCUR)
                fprintf(fid, ['\t\t\"', pname, '\" -> \"', cname, '\" [color = gray]; \n' ]);
            end
            if(ntypelist(i)==NODETYPES.SURROUND)
                fprintf(fid, ['\t\t\"', pname, '\" -> \"', cname, '\" [color = green]; \n' ]);
            end

   
    end
    
end
fprintf(fid, '\t } \n');
fprintf(fid, '\n');

fprintf(fid, '} \n');

end

