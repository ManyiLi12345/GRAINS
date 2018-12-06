function [ transform ] = genTransMat( front, up )
%GENTRANSMAT 

axes = cross(front,up);
axes = axes/norm(axes,2);
transform = [front(:)';up(:)';axes(:)'];

end

