function [ data ] = vis_wcf( label_list, obb_list )

linewidth = 2;
corlist = {[1,0.5,0.5,0.3],[0.5,0.7843,0.5,0.3],[0.5,0.5,1,0.3],[1,0.5,0,0.3],[0.1961,0.7843,1,0.3]};

front = [0,0,1];
up = [0,1,0];
axes = [1,0,0];

obblist = [obb_list(1:6,:);zeros(3,size(obb_list,2));obb_list(7:9,:)];
obblist(8,:) = 1;

for i = 1:length(label_list)
    if(i<3)
        % skip the visualization of floor and ceiling
        continue
    end
    p = obblist(:,i);
    
    center = p(1:3);
    lengths = p(10:12);
    
    dir_1 = p(4:6);
    dir_2 = p(7:9);
    dir_1 = dir_1/norm(dir_1);
    dir_2 = dir_2/norm(dir_2);
    dir_3 = cross(dir_1,dir_2);
    dir_3 = dir_3/norm(dir_3); 
    d1 = 0.5*lengths(1)*dir_1;
    d2 = 0.5*lengths(2)*dir_2;
    d3 = 0.5*lengths(3)*dir_3;

    cornerpoints(1,:) = center-d1-d2-d3;
    cornerpoints(2,:) = center+d1-d2-d3;
    cornerpoints(3,:) = center-d1-d2+d3;
    cornerpoints(4,:) = center+d1-d2+d3;
    cornerpoints(:,1) = 1 - cornerpoints(:,1);
    
    cor = corlist{mod(i-1,length(corlist))+1};
    plot([cornerpoints(1,1),cornerpoints(2,1)],[cornerpoints(1,3),cornerpoints(2,3)],'Color',cor(1:3),'linewidth',linewidth);
    hold on
    plot([cornerpoints(2,1),cornerpoints(4,1)],[cornerpoints(2,3),cornerpoints(4,3)],'Color',cor(1:3),'linewidth',linewidth);
    plot([cornerpoints(4,1),cornerpoints(3,1)],[cornerpoints(4,3),cornerpoints(3,3)],'Color',cor(1:3),'linewidth',linewidth);
    plot([cornerpoints(3,1),cornerpoints(1,1)],[cornerpoints(3,3),cornerpoints(1,3)],'Color',cor(1:3),'linewidth',linewidth);
	
	label = label_list{i};
	min_x = min(cornerpoints(:,1));
	max_z = max(cornerpoints(:,3));
	t = text(min_x+0.01,max_z-0.02,[label]);
	t.BackgroundColor = cor;
	t.FontSize = 8;
end

axis equal
axis off
fig = gcf;
fig.PaperUnits = 'points';
fig.PaperPosition = [0 0 224 224];%168 %108

f=getframe(gcf);
data=f.cdata;

end