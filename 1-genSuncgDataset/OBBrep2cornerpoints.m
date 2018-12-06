function [ cornerpoints ] = OBBrep2cornerpoints( p )

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

end

