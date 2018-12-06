function [ R,D ] = obbrelation( obb1, obb2, RELATIONS )

% compute relation R and relative distance D of two obbs
    
    R = RELATIONS.COOCCUR;

    cen1 = obb1(1,1:3);
    front1 = obb1(1,4:6);
    up1 = obb1(1,7:9);
    axis1 = cross(up1,front1);
    fsize1 = obb1(1,10);
    usize1 = obb1(1,11);
    asize1 = obb1(1,12);
    cornerpoints1 = OBBrep2cornerpoints(obb1);

    cen2 = obb2(1,1:3);
    front2 = obb2(1,4:6);
    up2 = obb2(1,7:9);
    axis2 = cross(up2,front2);
    fsize2 = obb2(1,10);
    usize2 = obb2(1,11);
    asize2 = obb2(1,12);
    cornerpoints2 = OBBrep2cornerpoints(obb2);
    
    isoverlap = zeros(6,1);
    isabove = zeros(2,1);
    overlap_ratio = -0.3;
    overlap_eps = -0.05;
    overlap_eps_ratio_lim = overlap_eps/overlap_ratio;
    attach_ratio = 0.1;
    attach_eps = 0.15;
    above_eps = 0;
    above_ratio = 0.15;
    
    % front1
    p2 = cornerpoints2*front1';
    nfsize2 = max(p2)-min(p2);
    len = abs((cen1-cen2)*front1');
    len = len - fsize1/2 - nfsize2/2;
    flen1 = len;
    minsize = min([fsize1,nfsize2]);
%     if(len<overlap_ratio*)
    if(len<overlap_eps)%||(minsize<overlap_eps_ratio_lim&&len<overlap_ratio*minsize))
        isoverlap(1,1) = 2;
    else
        if(len<attach_eps)
            isoverlap(1,1) = 1;
        end
    end
    
    % up1
    p2 = cornerpoints2*up1';
    nusize2 = max(p2)-min(p2);
    len = abs((cen1-cen2)*up1');
    len = len -usize1/2 - nusize2/2;
    ulen1 = len;
    minsize = min([usize1,nusize2]);
%     if(len<overlap_ratio*min([usize1,nusize2]))
    if(len<overlap_eps)%||(minsize<overlap_eps_ratio_lim&&len<overlap_ratio*minsize))
        isoverlap(2,1) = 2;
%     else if(len<nusize2*attach_ratio||len<attach_eps)
    else if(len<attach_eps)
            isoverlap(2,1) = 1;
        end
    end
    p1 = cornerpoints1*up1';
    rel_ulen1 = min(p2)-min(p1);
    if(rel_ulen1>usize1*above_ratio||(min(p2)-min(p1)>above_eps&&usize1<0.5))
        isabove(1,1) = 1;
    end
    
    % axis1
    p2 = cornerpoints2*axis1';
    nasize2 = max(p2)-min(p2);
    len = abs((cen1-cen2)*axis1');
    len = len -asize1/2 - nasize2/2;
    alen1 = len;
    minsize = min([asize1, nasize2]);
    if(len < overlap_eps)%||(minsize<overlap_eps_ratio_lim&&len<overlap_ratio*minsize))
        isoverlap(3,1) = 2;
    else if(len<attach_eps)
            isoverlap(3,1) = 1;
        end
    end
    
    % front2
    p1 = cornerpoints1*front2';
    nfsize1 = max(p1)-min(p1);
    len = abs((cen2-cen1)*front2');
    len = len - nfsize1/2 -fsize2/2;
    flen2 = len;
    minsize = min([nfsize1,fsize2]);
    if(len < overlap_eps)%||(minsize<overlap_eps_ratio_lim&&len<overlap_ratio*minsize))
        isoverlap(4,1) = 2;
    else if(len<attach_eps)
            isoverlap(4,1) = 1;
        end
    end
    
    % up2
    p1 = cornerpoints1*up2';
    nusize1 = max(p1)-min(p1);
    len = abs((cen2-cen1)*up2');
    len = len - nusize1/2 -usize2/2;
    ulen2 = len;
    minsize = min([nusize1,usize2]);
    if( len < overlap_eps)%||(minsize<overlap_eps_ratio_lim&&len<overlap_ratio*minsize))
        isoverlap(5,1) = 2;
    else if(len<attach_eps)
            isoverlap(5,1) = 1;
        end
    end
    p2 = cornerpoints2*up2';
    rel_ulen2 = min(p1)-min(p2);
    if(rel_ulen2>usize2*above_ratio||(min(p1)-min(p2)>above_eps&&usize2<0.5))
        isabove(2,1) = 1;
    end
    
    % axis2
    p1 = cornerpoints1*axis2';
    nasize1 = max(p1)-min(p1);
    len = abs((cen2-cen1)*axis2');
    len = len - nasize1/2 -asize2/2;
    alen2 = len;
    minsize = min([nasize1,asize2]);
    if(len < overlap_eps)%||(minsize<overlap_eps_ratio_lim&&len<overlap_ratio*minsize))
        isoverlap(6,1) = 2;
    else if(len<attach_eps)
            isoverlap(6,1) = 1;
        end
    end
   
    if(isoverlap(1,1)==2&&isoverlap(2,1)&&isoverlap(3,1)==2&&isabove(1,1))
        R = RELATIONS.SUPPORT1;
    end
    if(isoverlap(4,1)==2&&isoverlap(5,1)&&isoverlap(6,1)==2&&isabove(2,1))
        R = RELATIONS.SUPPORT2;
    end
    if((isoverlap(1,1)&&isoverlap(2,1)&&isoverlap(3,1))&&(isoverlap(4,1)&&isoverlap(5,1)&&isoverlap(6,1)))
        if(R~=RELATIONS.SUPPORT1&&R~=RELATIONS.SUPPORT2)
            R = RELATIONS.ATTACH;
        end
    end
    
    dir = cen2 - cen1;
    dir = dir/norm(dir,2);
    p1 = cornerpoints1*dir';
    p2 = cornerpoints2*dir';
    c1 = cen1*dir';
    c2 = cen2*dir';
    s1 = max(p1)-min(p1);
    s2 = max(p2)-min(p2);
%     D = norm(cen2-cen1,2) - sqrt(fsize1*fsize1+usize1*usize1+asize1*asize1) - sqrt(fsize2*fsize2+usize2*usize2+asize2*asize2);
%      D = (c2-c1)-s1/2 - s2/2;
%     D = min([max([flen1,ulen1,alen1]),max([flen2,ulen2,alen2])]);
    D = obbdist( obb1, obb2 );
    sidebyside_eps = 0.5;
    up_eps = 0.15;
    if(R==RELATIONS.COOCCUR&&D<sidebyside_eps&&isoverlap(2,1)&&isoverlap(5,1)&&(abs(rel_ulen1)<up_eps||abs(rel_ulen2)<up_eps))
        R = RELATIONS.SIDEBYSIDE;
    end

end

