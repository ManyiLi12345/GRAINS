function genBox( obb, filename )
%GENBOX 
cornerpoints = OBBrep2cornerpoints(obb);

fid = fopen(filename,'w');
for i = 1:size(cornerpoints,1)
	fprintf(fid, 'v  %f  %f  %f \n', cornerpoints(i,3), cornerpoints(i,1), cornerpoints(i,2));
end
fprintf(fid, 'f  %d  %d  %d %d \n', 4, 8, 7, 3);
fprintf(fid, 'f  %d  %d  %d %d \n', 8, 6, 5, 7);
fprintf(fid, 'f  %d  %d  %d %d \n', 6, 2, 1, 5);
fprintf(fid, 'f  %d  %d  %d %d \n', 2, 4, 3, 1);
fprintf(fid, 'f  %d  %d  %d %d \n', 4, 2, 6, 8);
fprintf(fid, 'f  %d  %d  %d %d \n', 7, 5, 1, 3);
fclose(fid);

end

