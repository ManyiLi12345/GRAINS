function [ final_sym, final_sur ] = search_surroundset( candidate_list, obblist, Rmat, Dmat, RELATIONS, LABELLEN )

% detect the surround relations: a set of similar objects around a central object
% OUTPUT: final_sym: a set of SAME objects around the central object
%         final_sur: a set of SIMILAR objects around the central object

objnum = size(obblist,1);
sym = {};
sur = {};

dist_thre = 0.05*7;
for i = 1:objnum
    Rlist = Rmat(i,:);
    Dlist = Dmat(i,:);
    idx = find(Rlist==RELATIONS.ATTACH|Rlist==RELATIONS.SIDEBYSIDE);
    samedist_list = {};
    matched_idx = [];
    for j = 1:length(idx)
        if(~ismember(j,matched_idx))
            d = Dlist(idx(j));
            idx1 = find(abs(Dlist(idx)-d)< dist_thre);
            samedist_list{length(samedist_list)+1} = idx(idx1);
            matched_idx = union(matched_idx,idx1);
        end
    end

    % now the samedist_list has all the lists store the objects of the whole
    % scene having close distance to the central object i
    for j = 1:length(samedist_list)
        slist = samedist_list{j};
        for k = 1:length(candidate_list)
            clist = candidate_list{k};
            idx = intersect(slist,clist);
            if(length(idx)>1)
                % idx is the list of object with similar size and similar
                % distance to object i
                label = obblist(idx(1),end-LABELLEN+1:end);
                [~,label] = max(label);
                ismatch = 1;
                for p = 1:length(idx)
                    plabel = obblist(idx(p),end-LABELLEN+1:end);
                    [~,plabel] = max(plabel);
                    if(plabel~=label)
                        ismatch = 0;
                        break;
                    end
                end
                if(ismatch)
                    % symmetry
                    sym{size(sym,1)+1,1} = idx;
                    sym{size(sym,1),2} = i;
                else
                    % surrounding
                    if(length(idx)>2)
                        sur{size(sur,1)+1,1} = idx;
                        sur{size(sur,1),2} = i;
                    end
                end
                
            end
        end
    end
end

%% remove the redundant pairs in sym and sur
final_sym = {};
final_sur = {};
% if a set of object is a subset of others, then it's deleted
for i = 1:size(sym,1)
    sy = sym{i,1};
    issurvived = 1;
    for j = 1:size(final_sym,1)
        idx = setdiff(sy,final_sym{j,1});
        if(length(idx)==0)
            issurvived = 0;
            break;
        end
    end
    if(issurvived)
        for j = 1:size(final_sur,1)
            idx = setdiff(sy,sur{j,1});
            if(length(idx)==0)
            	issurvived = 0;
                break;                
            end
        end
    end
    if(issurvived)
        final_sym{size(final_sym,1)+1,1} = sy;
        final_sym{size(final_sym,1),2} = sym{i,2};
    end
end

for i = 1:size(sur,1)
    su = sur{i,1};
    issurvived = 1;
    for j = 1:size(final_sym,1)
        idx = setdiff(su,final_sym{j,1});
        if(length(idx)==0)
            issurvived = 0;
            break;
        end
    end
    if(issurvived)
        for j = 1:size(final_sur,1)
            idx = setdiff(su,sur{j,1});
            if(length(idx)==0)
            	issurvived = 0;
                break;                
            end
        end
    end
    if(issurvived)
        final_sur{size(final_sur,1)+1,1} = su;
        final_sur{size(final_sur,1),2} = sur{i,2};
    end
end

sym = final_sym;
sur = final_sur;
% final_sym = {};
% final_sur = {};
% % if a set of object is a subset of others, then it's deleted
% for i = 1:size(sym,1)
%     sy = sym{i,1};
%     issurvived = 1;
%     for j = 1:size(final_sym,1)
%         idx = setdiff(sy,final_sym{j,1});
%         if(length(idx)==0)
%             issurvived = 0;
%             break;
%         end
%     end
%     if(issurvived)
%         for j = 1:size(final_sur,1)
%             idx = setdiff(sy,sur{j,1});
%             if(length(idx)==0)
%             	issurvived = 0;
%                 break;                
%             end
%         end
%     end
%     if(issurvived)
%         final_sym{length(final_sym)+1,1} = sy;
%     end
% end

end

