function dec = signBin2dec(bin)

columns = length(bin(:,1));
rows = length(bin(1,:));

bin_buff = char(zeros(columns,rows));
dec_buff = zeros(columns,1);

for i = 1:columns
    for j = 1:rows
        if bin(i,1) == "1"
            if bin(i,j) == "0"
                bin_buff(i,j) = "1";
            else
                bin_buff(i,j) = "0";
            end

            if j == rows
                dec_buff(i,1) = -1*(bin2dec(bin_buff(i,2:end)) + 1);
            end
        else
            bin_buff(i,j) = bin(i,j);
            if j == rows
                dec_buff(i,1) = bin2dec(bin_buff(i,2:end));
            end
        end
    end
end

dec = dec_buff;

end