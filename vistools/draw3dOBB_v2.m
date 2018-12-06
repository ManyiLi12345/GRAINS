function draw3dOBB_v2(p, col)

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

plot3([cornerpoints(1,1),cornerpoints(2,1)],[cornerpoints(1,2),cornerpoints(2,2)],[cornerpoints(1,3),cornerpoints(2,3)],col);hold on;
plot3([cornerpoints(1,1),cornerpoints(3,1)],[cornerpoints(1,2),cornerpoints(3,2)],[cornerpoints(1,3),cornerpoints(3,3)],col);hold on;
plot3([cornerpoints(2,1),cornerpoints(4,1)],[cornerpoints(2,2),cornerpoints(4,2)],[cornerpoints(2,3),cornerpoints(4,3)],col);hold on;
plot3([cornerpoints(3,1),cornerpoints(4,1)],[cornerpoints(3,2),cornerpoints(4,2)],[cornerpoints(3,3),cornerpoints(4,3)],col);hold on;
plot3([cornerpoints(5,1),cornerpoints(6,1)],[cornerpoints(5,2),cornerpoints(6,2)],[cornerpoints(5,3),cornerpoints(6,3)],col);hold on;
plot3([cornerpoints(5,1),cornerpoints(7,1)],[cornerpoints(5,2),cornerpoints(7,2)],[cornerpoints(5,3),cornerpoints(7,3)],col);hold on;
plot3([cornerpoints(6,1),cornerpoints(8,1)],[cornerpoints(6,2),cornerpoints(8,2)],[cornerpoints(6,3),cornerpoints(8,3)],col);hold on;
plot3([cornerpoints(7,1),cornerpoints(8,1)],[cornerpoints(7,2),cornerpoints(8,2)],[cornerpoints(7,3),cornerpoints(8,3)],col);hold on;
plot3([cornerpoints(1,1),cornerpoints(5,1)],[cornerpoints(1,2),cornerpoints(5,2)],[cornerpoints(1,3),cornerpoints(5,3)],col);hold on;
plot3([cornerpoints(2,1),cornerpoints(6,1)],[cornerpoints(2,2),cornerpoints(6,2)],[cornerpoints(2,3),cornerpoints(6,3)],col);hold on;
plot3([cornerpoints(3,1),cornerpoints(7,1)],[cornerpoints(3,2),cornerpoints(7,2)],[cornerpoints(3,3),cornerpoints(7,3)],col);hold on;
plot3([cornerpoints(4,1),cornerpoints(8,1)],[cornerpoints(4,2),cornerpoints(8,2)],[cornerpoints(4,3),cornerpoints(8,3)],col);hold on;

arrow_len = 0.3;
plot3([center(1),center(1)+dir_1(1)*arrow_len], [center(2),center(2)+dir_1(2)*arrow_len], [center(3),center(3)+dir_1(3)*arrow_len], 'r');
plot3([center(1),center(1)+dir_2(1)*arrow_len], [center(2),center(2)+dir_2(2)*arrow_len], [center(3),center(3)+dir_2(3)*arrow_len],'b');

end

