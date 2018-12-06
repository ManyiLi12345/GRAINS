function saveOBBs(obblist,filename)

fid = fopen(filename,'wt');

for i = 1:size(obblist,1)
    p = obblist(i,:);
    
    center = p(1:3);
    dir_1 = p(4:6);
    dir_2 = p(7:9);
    lengths = p(10:12);

    dir_1 = dir_1/norm(dir_1);
    dir_2 = dir_2/norm(dir_2);
    dir_3 = cross(dir_1,dir_2);
    dir_3 = dir_3/norm(dir_3); 
    cornerpoints = zeros(8,3);

    d1 = 0.5*lengths(1)*dir_1;
    d2 = 0.5*lengths(2)*dir_2;
    d3 = 0.5*lengths(3)*dir_3;
    cornerpoints(1,:) = center-d1-d2-d3;
    cornerpoints(2,:) = center-d1+d2-d3;
    cornerpoints(3,:) = center+d1-d2-d3;
    cornerpoints(4,:) = center+d1+d2-d3;
    cornerpoints(5,:) = center-d1-d2+d3;
    cornerpoints(6,:) = center-d1+d2+d3;
    cornerpoints(7,:) = center+d1-d2+d3;
    cornerpoints(8,:) = center+d1+d2+d3;
    
    for j = 1:size(cornerpoints,1)
        fprintf(fid,'v  %f  %f  %f  \n',cornerpoints(j,1),cornerpoints(j,2),cornerpoints(j,3)); 
    end
end

N = 8;
for i = 1:size(obblist,1)
    fprintf(fid,'f  %d  %d  %d\n',(i-1)*N+6,(i-1)*N+4,(i-1)*N+2);
    fprintf(fid,'f  %d  %d  %d\n',(i-1)*N+6,(i-1)*N+8,(i-1)*N+4);
    fprintf(fid,'f  %d  %d  %d\n',(i-1)*N+8,(i-1)*N+7,(i-1)*N+4);
    fprintf(fid,'f  %d  %d  %d\n',(i-1)*N+7,(i-1)*N+3,(i-1)*N+4);
    fprintf(fid,'f  %d  %d  %d\n',(i-1)*N+7,(i-1)*N+5,(i-1)*N+3);
    fprintf(fid,'f  %d  %d  %d\n',(i-1)*N+5,(i-1)*N+2,(i-1)*N+1);
    fprintf(fid,'f  %d  %d  %d\n',(i-1)*N+5,(i-1)*N+6,(i-1)*N+2);
    fprintf(fid,'f  %d  %d  %d\n',(i-1)*N+4,(i-1)*N+3,(i-1)*N+1);
    fprintf(fid,'f  %d  %d  %d\n',(i-1)*N+2,(i-1)*N+4,(i-1)*N+1);
    fprintf(fid,'f  %d  %d  %d\n',(i-1)*N+5,(i-1)*N+8,(i-1)*N+6);
    fprintf(fid,'f  %d  %d  %d\n',(i-1)*N+5,(i-1)*N+7,(i-1)*N+8);
end

fclose(fid);
% plot3([cornerpoints(1,1),cornerpoints(2,1)],[cornerpoints(1,2),cornerpoints(2,2)],[cornerpoints(1,3),cornerpoints(2,3)],col);hold on;
% plot3([cornerpoints(1,1),cornerpoints(3,1)],[cornerpoints(1,2),cornerpoints(3,2)],[cornerpoints(1,3),cornerpoints(3,3)],col);hold on;
% plot3([cornerpoints(2,1),cornerpoints(4,1)],[cornerpoints(2,2),cornerpoints(4,2)],[cornerpoints(2,3),cornerpoints(4,3)],col);hold on;
% plot3([cornerpoints(3,1),cornerpoints(4,1)],[cornerpoints(3,2),cornerpoints(4,2)],[cornerpoints(3,3),cornerpoints(4,3)],col);hold on;
% plot3([cornerpoints(5,1),cornerpoints(6,1)],[cornerpoints(5,2),cornerpoints(6,2)],[cornerpoints(5,3),cornerpoints(6,3)],col);hold on;
% plot3([cornerpoints(5,1),cornerpoints(7,1)],[cornerpoints(5,2),cornerpoints(7,2)],[cornerpoints(5,3),cornerpoints(7,3)],col);hold on;
% plot3([cornerpoints(6,1),cornerpoints(8,1)],[cornerpoints(6,2),cornerpoints(8,2)],[cornerpoints(6,3),cornerpoints(8,3)],col);hold on;
% plot3([cornerpoints(7,1),cornerpoints(8,1)],[cornerpoints(7,2),cornerpoints(8,2)],[cornerpoints(7,3),cornerpoints(8,3)],col);hold on;
% plot3([cornerpoints(1,1),cornerpoints(5,1)],[cornerpoints(1,2),cornerpoints(5,2)],[cornerpoints(1,3),cornerpoints(5,3)],col);hold on;
% plot3([cornerpoints(2,1),cornerpoints(6,1)],[cornerpoints(2,2),cornerpoints(6,2)],[cornerpoints(2,3),cornerpoints(6,3)],col);hold on;
% plot3([cornerpoints(3,1),cornerpoints(7,1)],[cornerpoints(3,2),cornerpoints(7,2)],[cornerpoints(3,3),cornerpoints(7,3)],col);hold on;
% plot3([cornerpoints(4,1),cornerpoints(8,1)],[cornerpoints(4,2),cornerpoints(8,2)],[cornerpoints(4,3),cornerpoints(8,3)],col);hold on;

end

