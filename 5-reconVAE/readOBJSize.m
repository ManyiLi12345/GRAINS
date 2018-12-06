function [ msize ] = readOBJSize( filename )
%READOBJSIZE open an .obj file and return the obj size
fid = fopen(filename);
v = []; f = {};
while 1
        tline = fgetl(fid);
        if ~ischar(tline),   break,   end  % exit at end of file
        ln = sscanf(tline,'%s',1); % line type
        switch ln
            case 'v'   % mesh vertexs
                v = [v; sscanf(tline(2:end),'%f')'];
            case 'f'
                face = strsplit(tline(2:end));
                nface = [];
                for k = 2:length(face)
                    nface(k-1) = sscanf(face{k},'%d');
                end
                f{length(f)+1} = nface;
        end
end
fclose(fid);

mid = (max(v)+min(v))/2;
v = v-repmat(mid,size(v,1),1);
msize = max(v)-min(v);


end

