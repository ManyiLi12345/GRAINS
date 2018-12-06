function [ D ] = obbdist( obb1, obb2 )

    cen1 = obb1(1,1:3);
    front1 = obb1(1,4:6);
    up1 = obb1(1,7:9);
    axis1 = cross(up1,front1);
    fsize1 = obb1(1,10);
    usize1 = obb1(1,11);
    asize1 = obb1(1,12);
    cornerpoints1 = OBBrep2cornerpoints(obb1);
    c1 = cen1*[front1;up1;axis1]';
    p1_min = c1 - [fsize1,usize1,asize1]/2;
    p1_max = c1 + [fsize1,usize1,asize1]/2;

    cen2 = obb2(1,1:3);
    front2 = obb2(1,4:6);
    up2 = obb2(1,7:9);
    axis2 = cross(up2,front2);
    fsize2 = obb2(1,10);
    usize2 = obb2(1,11);
    asize2 = obb2(1,12);
    cornerpoints2 = OBBrep2cornerpoints(obb2);
    c2 = cen2*[front2;up2;axis2]';
    p2_min = c2 - [fsize2,usize2,asize2]/2;
    p2_max = c2 + [fsize2,usize2,asize2]/2;
    
    % p2 to face1
    fl2 = cornerpoints2*front1';
    ul2 = cornerpoints2*up1';
    al2 = cornerpoints2*axis1';
    d21_2 = zeros(8,1);
    
    c1 = [cen1*front1',cen1*up1',cen1*axis1'];
    len = abs(fl2-c1(1,1))-fsize1/2;
    idx = find(len>0);
    d21_2(idx,1) = d21_2(idx,1)+len(idx).^2;
    len = abs(ul2-c1(1,2))-usize1/2;
    idx = find(len>0);
    d21_2(idx,1) = d21_2(idx,1)+len(idx).^2;
    len = abs(al2-c1(1,3))-asize1/2;
    idx = find(len>0);
    d21_2(idx,1) = d21_2(idx,1)+len(idx).^2;
    d21_2 = sqrt(d21_2);
    
    % p1 to face2
    fl1 = cornerpoints1*front2';
    ul1 = cornerpoints1*up2';
    al1 = cornerpoints1*axis2';
    d12_2 = zeros(8,1);
    
    c2 = [cen2*front2',cen2*up2',cen2*axis2'];
    len = abs(fl1-c2(1,1))-fsize2/2;
    idx = find(len>0);
    d12_2(idx,1) = d12_2(idx,1)+len(idx).^2;
    len = abs(ul1-c2(1,2))-usize2/2;
    idx = find(len>0);
    d12_2(idx,1) = d12_2(idx,1)+len(idx).^2;
    len = abs(al1-c2(1,3))-asize2/2;
    idx = find(len>0);
    d12_2(idx,1) = d12_2(idx,1)+len(idx).^2;
    d12_2 = sqrt(d12_2);
    
    D = min([d21_2;d12_2]);
    
end

