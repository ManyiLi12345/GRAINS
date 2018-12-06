function [ sym ] = search_symmetryset( candidate_list, obblist, Rmat, Dmat, LABELLEN )

objnum = size(obblist,1);
sym = {};
height_thre = 0.1*7;

%% search for the symmetry without central object
for i = 1:length(candidate_list)
    clist = candidate_list{i};
    clabellist = zeros(size(clist));
    csublists = {};
    for j = 1:length(clist)
        label = obblist(clist(j),end-LABELLEN+1:end);
        label = binary2dec(label);
        clabellist(j) = label;
    end
    ls = unique(clabellist);
    for j = 1:length(ls)
        label = ls(j);
        idx = find(clabellist==label);
        csublists{length(csublists)+1} = clist(idx);
        % "csublists" stores the sublists with same labels (and same size)
    end

    
    for j = 1:length(csublists)
        cslist = csublists{j};
        if(length(cslist)<=1)
            continue;
        end
        dists = Dmat(cslist, cslist);
        symdist_thre = 0.05*7;

        dl = unique(dists);
        dl = sort(dl);
        
        ismatched = zeros(1,length(cslist));
        for k = 1:length(dl)
            mind = dl(k);
            
            cssublists = {};
            for p = 1:length(cslist)
                for q = 1:length(cslist)
                    if(p~=q&&abs(Dmat(cslist(p),cslist(q))-mind)<symdist_thre)
                        isadded = -1;
                        for v = 1:size(cssublists,1)
                            if(ismember(cslist(p),cssublists{v,1})&&isadded==-1)
                                if(ismatched(q)~=1)
                                    if(abs(obblist(cslist(p),2)-obblist(cslist(q),2))<height_thre)
                                        cssublists{v,1} = union(cssublists{v,1},cslist(q));
                                        ismatched(q)=1;
                                        isadded = 1;
                                        break;
                                    end
                                end
                            end
                            if(ismember(cslist(q),cssublists{v,1})&&isadded==-1)
                                if(ismatched(p)~=1)
                                    if(abs(obblist(cslist(p),2)-obblist(cslist(q),2))<height_thre)
                                        cssublists{v,1} = union(cssublists{v,1},cslist(p));
                                        ismatched(p)=1;
                                        isadded = 1;
                                        break;
                                    end
                                end
                            end
                        end
                        if(isadded==-1)
                            if(ismatched(p)~=1&&ismatched(q)~=1)
                                if(abs(obblist(cslist(p),2)-obblist(cslist(q),2))<height_thre)
                                    cssublists{size(cssublists,1)+1,1} = [cslist(p),cslist(q)];
                                    cssublists{size(cssublists,1),2} = mind;
                                    ismatched(p)=1;
                                    ismatched(q)=1;
                                end
                            end
                        end
                    end
                end
            end
            for v = 1:size(cssublists,1)
                csslist = cssublists{v,1};
                % add sym
                sym{size(sym,1)+1,1} = csslist;
                sym{size(sym,1),2} = cssublists{v,2};
            end
        end

    end
end

final_sym = {};
% one object can be involved in one symmetry relation
isinvolved = zeros(1,objnum);
for i = 1:objnum
    if(isinvolved(i)~=1)
        symlist = {};
        symdist = [];
        if(size(sym,1)>0)
            for j = 1:size(sym,1)
                if(ismember(i,sym{j,1}))
                    symlist{length(symlist)+1}= sym{j,1};
                    sdist = Dmat(i,sym{j,1});
                    maxd = max(sdist(:));
                    for k = 1:size(sdist,1)
                        sdist(k,k) = k+maxd;
                    end
                    symdist(length(symlist)) = min(sdist);
                end
            end
            if(length(symdist)>0)
                [md,I] = min(symdist);
                symlist = symlist{I};
            end
        end


        if(length(symlist)>1)
            final_sym{size(final_sym,1)+1,1} = symlist;
            final_sym{size(final_sym,1),2} = md;
            isinvolved(symlist) = 1;
        end
    end
end
sym = final_sym;

end

