function [signal, time] = open_wfdb(file_name)
% 1. Read bianry file
fileID = fopen([file_name '.dat'], 'r');
if fileID == -1
    error('File not found.');
end
data = fread(fileID, [3, inf], 'uint8')';
fclose(fileID);

% 2. Open bits automatically (format 212)
M1 = bitshift(bitand(data(:, 2), 15), 8) + data(:, 1);
M2 = bitshift(bitshift(bitand(data(:, 2), 240), -4), 8) + data(:, 3);

M1(M1 > 2047) = M1(M1 > 2047) - 4096;
M2(M2 > 2047) = M2(M2 > 2047) - 4096;

% 3. convert to physical data (Milivolts)
signal = [(M1 - 1024)/200, (M2 - 1024)/200];
time = (0:length(M1)-1)' / 360;


end
