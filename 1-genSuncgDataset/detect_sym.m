function [final_sur ] = detect_sym( obblist, Rmat, Dmat, RELATIONS, LABELLEN )

% detect the surround and symmetry relations in the obblist
% The symmetry relation is disabled in this version

% checked_label = [];
% load(pathparam.label2vec_filename);
% box_vec = label2vec_map('Box');
% box_label = binary2dec(box_vec{1});

% search for the candidate_list
% each candidate is a list of objects with similar sizes which may be
% involved in a symmetry or surround relation
objnum = size(obblist,1);
sizelist = obblist(:,10:12);
size_thre = 0.03;
matched = [];
candidate_list = {};
for i = 1:objnum
    idx = find(matched==i);
    if(length(idx)==0)
        delta = abs(sizelist - repmat(sizelist(i,:),objnum,1));
        delta = delta - size_thre;
        delta = delta(:,1)+delta(:,2)+delta(:,3);
        idx = find(delta<=0);
        matched = union(matched,idx);
        if(length(idx)>1)
            candidate_list{length(candidate_list)+1} = idx;
        end
    end
end

%% extract the objects with similar heights in each candidate
ncandidate_list = {};
up = [0;1;0];
height_thre = 0.1;
for i = 1:length(candidate_list)
    clist = candidate_list{i};
    heights = obblist(clist,1:3)*up;
    matchednums = zeros(length(clist),1);
    for j = 1:length(clist)
        tmplist = abs(heights-heights(j));
        ind = find(tmplist<height_thre);
        matchednums(j) = length(ind);
    end
    [~,I] = max(matchednums);
    tmplist = abs(heights-heights(j));
	ind = find(tmplist<height_thre);
  	if(length(ind)>1)
        ncandidate_list{length(ncandidate_list)+1} = clist(ind);
    end
end
candidate_list = ncandidate_list;


%% search for all sets without central obj
% [ sym ] = search_symmetryset( candidate_list, obblist, Rmat, Dmat, LABELLEN );
%% search for all sets surrounding one obj
[ cen_sym, cen_sur ] = search_surroundset( candidate_list, obblist, Rmat, Dmat, RELATIONS, LABELLEN );
sur = {};
for i = 1:size(cen_sym,1)
    sur{size(sur,1)+1,1} = cen_sym{i,1};
    sur{size(sur,1),2} = cen_sym{i,2};
end
for i = 1:size(cen_sur,1)
    sur{size(sur,1)+1,1} = cen_sur{i,1};
    sur{size(sur,1),2} = cen_sur{i,2};
end
% sur = [cen_sym,cen_sur];

% sort the sur pairs based on the distance
dlist = zeros(size(sur,1),1);
for i = 1:size(sur,1)
    list = sur{i,1};
    c = sur{i,2};
    dlist(i) = Dmat(list(1),c);
end
[~,I] = sort(dlist);
sur = sur(I,:);

% except for the central object, each object can only be involved in one surround relation
isinvolved = zeros(size(obblist,1),1);
final_sur = {};
for i = 1:size(sur,1)
    list = sur{i,1};
    if(sum(isinvolved(list))==0)
        % add this surround pair
        s = [sur{i,2};list(:)];
        final_sur{length(final_sur)+1} = s;
    end
end


end
