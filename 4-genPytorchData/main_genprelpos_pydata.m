clear;clc;
util;
load(data_filename);

data = dataset;
dataNum = length(data);

BOX = 0;
SUPPORT = 1;
GROUP = 2;
SURROUND = 3;
ROOM = 4;
WALL = 5;

maxBoxes = 25;
maxOps = 50;
maxRelpos = 50;
maxNodenum = 50;
maxDepth = 20;
copies = 1;

leafSize = size(data{1}.leafreps,1);
relposSize = 28;

boxes = zeros(leafSize, maxBoxes*dataNum*copies);
ops = zeros(maxOps,dataNum*copies);
relposes = zeros(relposSize, maxRelpos*dataNum*copies);
weights = zeros(1,dataNum*copies);

for i = 1:dataNum
    p_index = i;
    
    leafreps = data{p_index}.leafreps; % input of leaf nodes
    kids = data{p_index}.kids;
    relposreps = data{p_index}.relposreps;
    
    r = 0;
    for j = 1:length(relposreps)
        rp = relposreps{j};
        r = r+size(rp,2);
    end
    
    b = size(leafreps,2); % number of leaf nodes
    l = length(kids); % number of all nodes
    tbox = zeros(leafSize, b);
    top = -ones(1,l);
    trelpos = -ones(relposSize, r)*2;
    
    box = zeros(leafSize, maxBoxes); % data to be saved
    op = -ones(maxOps,1); % data to be saved
    relpos = zeros(relposSize, maxRelpos); % data to be saved
    
    k = kids{l};
    stack = k(2:end)';
    top(1) = k(1);
    
    relposcount = 1;
    rp = relposreps{l};
    for j = 3:length(k)
        rel = rp(:,j-2);
        trelpos(:,relposcount) = rel;
        relposcount = relposcount+1;
    end
            
    count = 2;
    boxcount = 1;
    
    while length(stack) ~= 0
        idx = length(stack);
        node = stack(idx);
        stack(idx) = [];
        k = kids{node};
        rp = relposreps{node};
        flag = k(1);
        if flag==BOX
            top(count) = BOX;
            tbox(:, boxcount) = leafreps(:, node);
            count = count + 1;
            boxcount = boxcount + 1;
            continue;
        end
        if flag==SUPPORT
            top(count) = SUPPORT;
            stack(idx:idx+length(k)-2) = (k(2:end));
            for j = 3:length(k)
                rel = rp(:,j-2);
                trelpos(:,relposcount) = rel;
                relposcount = relposcount+1;
            end
            count = count + 1;
            continue;
        end
        if flag==GROUP
            top(count) = GROUP;
            stack(idx:idx+length(k)-2) = (k(2:end));
            for j = 3:length(k)
                rel = rp(:,j-2);
                trelpos(:,relposcount) = rel;
                relposcount = relposcount+1;
            end
            count = count + 1;
            continue;
        end
        if flag==SURROUND
            top(count) = SURROUND;
            stack(idx:idx+length(k)-2) = (k(2:end));
            for j = 3:length(k)
                rel = rp(:,j-2);
                trelpos(:,relposcount) = rel;
                relposcount = relposcount+1;
            end
            count = count + 1;
            continue;
        end
        if flag==ROOM
            top(count) = ROOM;
            stack(idx:idx+length(k)-2) = (k(2:end));
            for j = 3:length(k)
                rel = rp(:,j-2);
                trelpos(:,relposcount) = rel;
                relposcount = relposcount+1;
            end
            count = count + 1;
            continue;
        end
        if flag==WALL
            top(count) = WALL;
            stack(idx:idx+length(k)-2) = (k(2:end));
            for j = 3:length(k)
                rel = rp(:,j-2);
                trelpos(:,relposcount) = rel;
                relposcount = relposcount+1;
            end
            count = count + 1;
            continue;
        end
    end
    top = fliplr(top);
    tbox = fliplr(tbox);
    trelpos = fliplr(trelpos);
    
    box(:, 1:b) = tbox;
    op(1:l, 1) = top';
    relpos(:,1:r) = trelpos;
    
    box = repmat(box, 1, copies);
    op = repmat(op, 1, copies);
    relpos = repmat(relpos, 1, copies);
    boxes(:, (i-1)*maxBoxes*copies+1:i*maxBoxes*copies) = box;
    ops(:,(i-1)*copies+1:i*copies) = op;
    relposes(:,(i-1)*maxRelpos*copies+1:i*maxRelpos*copies) = relpos;
    weights(:, (i-1)*copies+1:i*copies) = b/maxBoxes;
end

save([output_folder, filesep, 'boxes.mat'],'boxes');
save([output_folder, filesep, 'ops.mat'],'ops');
save([output_folder, filesep, 'relpos.mat'], 'relposes');
% save('weights.mat','weights');
% save('attach.mat', 'attachs');