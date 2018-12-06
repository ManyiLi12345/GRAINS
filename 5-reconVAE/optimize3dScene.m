function [ rdata ] = optimize3dScene( rdata )
%OPTIMIZE3DSCENE optimize the layout of 3d scene
% INPUT: rdata - including:
%                               (1) obblist, absolute positions of boxes
%                               (2) kids, hierarchy
kids = rdata.kids;
obblist = rdata.obblist;

%% adjust the object heights
%  recon the usize of all nodes
usizelist = zeros(length(kids),1);
usizelist(1:size(obblist,2)) = obblist(11,:);
for i = 1:length(kids)
    k = kids{i};
    flag = k(1);
    if(length(k)>1)
        switch(flag)
            case 1
                % support
                usize1 = usizelist(k(2));
                usize2 = usizelist(k(3));
                usizelist(i) = usize1+usize2;       
            case 4
                usize1 = usizelist(k(2));
                usize(1) = usizelist(k(3));
                usize(2) = usizelist(k(4));
                usize(3) = usizelist(k(5));
                usize(4) = usizelist(k(6));
                usize = max(usize);
                usizelist(i) = usize1+usize;  
            otherwise
                csizelist = usizelist(k(2:end));
                usizelist(i) = max(csizelist);
        end
    end
end

% compute the heights
nodeheight = zeros(length(kids),1);
for i = length(kids):-1:1
    k = kids{i};
    flag = k(1);
    pheight = nodeheight(i);
    switch(flag)
        case 1
            % support
            nodeheight(k(2)) = pheight;
            nodeheight(k(3)) = pheight+usizelist(k(2));
        case 4
            nodeheight(k(2)) = pheight;
            nodeheight(k(3:end)) = pheight+usizelist(k(2));
        otherwise
            nodeheight(k(2:end)) = pheight;
    end
end

% fill the cent(2) in the obblist
for i = 1:size(obblist,2)
    obblist(2,i) = nodeheight(i)+obblist(11,i)/2;
end
rdata.obblist = obblist;

end

