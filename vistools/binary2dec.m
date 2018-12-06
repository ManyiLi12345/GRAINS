function [ num ] = binary2dec( vec )

num = 0;
for i = 1:length(vec)
    num = num + vec(i)*(2^(i-1));
end

end

