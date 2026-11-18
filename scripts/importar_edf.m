function [sig, t, ch_name] = open_edf(filename)
% function for reading edfs

fid = fopen(filename, 'r');
if fid < 0
    error('Error opening the file');
end

% basic header
fseek(fid, 236, 'bof');
fread(fid, 8, '*char'); 
dur = str2double(fread(fid, 8, '*char')');
ns = str2double(fread(fid, 4, '*char')'); % num of signals

% Eextract channels names
labels = cell(ns, 1);
for i = 1:ns
    labels{i} = strtrim(fread(fid, 16, '*char')');
end

% Factors for calibration
fseek(fid, 256 + ns * 104, 'bof');
pmin = zeros(ns, 1); pmax = zeros(ns, 1);
dmin = zeros(ns, 1); dmax = zeros(ns, 1);

for i=1:ns, pmin(i) = str2double(fread(fid, 8, '*char')'); end
for i=1:ns, pmax(i) = str2double(fread(fid, 8, '*char')'); end
for i=1:ns, dmin(i) = str2double(fread(fid, 8, '*char')'); end
for i=1:ns, dmax(i) = str2double(fread(fid, 8, '*char')'); end

% samples from blocks 
fseek(fid, 256 + ns * 216, 'bof');
samples = zeros(ns, 1);
for i=1:ns, samples(i) = str2double(fread(fid, 8, '*char')'); end

% find the first valid channel 
ch_idx = 1;
for i = 1:ns
    if ~contains(labels{i}, 'Annotation') && ~contains(labels{i}, 'Record')
        ch_idx = i;
        break;
    end
end
ch_name = labels{ch_idx};

% read the whole matrix
fseek(fid, 256 + ns * 256, 'bof');
raw_data = fread(fid, inf, 'int16');
fclose(fid);

% demultiplex matrix
bloques = reshape(raw_data, sum(samples), []);
ini = sum(samples(1:ch_idx-1)) + 1;
fin = sum(samples(1:ch_idx));

sig_raw = bloques(ini:fin, :);
sig_raw = sig_raw(:); 

% change to mV
gain = (pmax(ch_idx) - pmin(ch_idx)) / (dmax(ch_idx) - dmin(ch_idx));
offset = pmax(ch_idx) - gain * dmax(ch_idx);

sig = sig_raw * gain + offset;

% time vector 
fs = samples(ch_idx) / dur;
t = (0:length(sig)-1)' / fs;
end
