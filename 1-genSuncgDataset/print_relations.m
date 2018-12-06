function [ output_args ] = print_relations( p_data, filename, RELATIONS )


fid = fopen(filename,'wt');
fprintf(fid, 'digraph G { \n');
fprintf(fid, '\t ratio = fill \n');
fprintf(fid, '\t node [style = filled] \n');

% corlist = {[1,0,0,0.3],[0,1,0,0.3],[0,1,1,0.3],[0,0,1,0.3],[1,0,1,0.3]};
corlist = {'red','green','cyan','blue','purple'};

%% print the nodes
for i = 1:length(p_data.labellist)
    cor = corlist{mod(i-1,length(corlist))+1};
    namei = p_data.labellist{i};
    namei = [namei, num2str(i)];
%     fprintf(fid, ['\t\"', namei, '\" [color = ', cor, ']; \n' ]);
    fprintf(fid, ['\t\"', namei, '\"; \n' ]);
end
fprintf(fid, '\n');

Rmat = p_data.Rmat;


%% print the support relations with directed edges
fprintf(fid, '\t subgraph suppG { \n');
for i = 1:size(Rmat,1)
    namei = p_data.labellist{i};
    namei = [namei,num2str(i)];
    for j = i+1:size(Rmat,2)
        namej = p_data.labellist{j};
        namej = [namej,num2str(j)];
        
        R = Rmat(i,j);
        if R==RELATIONS.SUPPORT1
            fprintf(fid, ['\t\t\"', namei, '\" -> \"', namej, '\" [color = red]; \n' ]);
        end
        if R==RELATIONS.SUPPORT2
            fprintf(fid, ['\t\t\"', namej, '\" -> \"', namei, '\" [color = red]; \n' ]);
        end
    end
end
fprintf(fid, '\t } \n');
fprintf(fid, '\n');

%% print the attach and sidebyside relations with undirected edges
fprintf(fid, '\t subgraph nearbyG { \n');
fprintf(fid, '\t\t edge [dir=none] \n');
for i = 1:size(Rmat,1)
    namei = p_data.labellist{i};
    namei = [namei,num2str(i)];
    for j = i+1:size(Rmat,2)
        namej = p_data.labellist{j};
        namej = [namej,num2str(j)];
        
        R = Rmat(i,j);
        if R==RELATIONS.ATTACH
            fprintf(fid, ['\t\t\"', namei, '\" -> \"', namej, '\" [color = green]; \n' ]);
        end
        if R==RELATIONS.SIDEBYSIDE
            fprintf(fid, ['\t\t\"', namei, '\" -> \"', namej, '\" [color = gray]; \n' ]);
        end
    end
end
fprintf(fid, '\t } \n');
fprintf(fid, '\n');


% print symmetry relations
fprintf(fid, '\t subgraph symG { \n');
fprintf(fid, '\t\t edge [dir=none] \n');
if(isfield(p_data,'sym'))
    sym = p_data.sym;
    for i = 1:length(sym)
        slist = sym{i};
        for i1 = 1:length(slist)-1
            namei = p_data.labellist{slist(i1)};
            namei = [namei, num2str(slist(i1))];
            namej = p_data.labellist{slist(i1+1)};
            namej = [namej, num2str(slist(i1+1))];
        fprintf(fid, ['\t\t\"', namei, '\" -> \"', namej, '\" [color = blue]; \n' ]);
        end
    end
end

% print symmetry relations
if(isfield(p_data,'sur'))
    sur = p_data.sur;
    for i = 1:length(sur)
        slist = sur{i};
        for i1 = 1:length(slist)-1
            namei = p_data.labellist{slist(i1)};
            namei = [namei, num2str(slist(i1))];
            namej = p_data.labellist{slist(i1+1)};
            namej = [namej, num2str(slist(i1+1))];
        fprintf(fid, ['\t\t\"', namei, '\" -> \"', namej, '\" [color = purple]; \n' ]);
        end
    end
end
fprintf(fid, '\t } \n');
fprintf(fid, '\n');

fprintf(fid, '}');
fclose(fid);

end

