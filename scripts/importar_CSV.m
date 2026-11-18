function [sig, t, ch_name] = open_csv(filename)
%load tabular data form column position

% Read file
tbl = readtable(filename);

% extract from each postion: Col 1 = time, Col 2 = data
t = tbl{:, 1};
sig = tbl{:, 2};

% try to take the original name of the chanels
vars = tbl.Properties.VariableNames;
if length(vars) >= 2
    ch_name = vars{2};
else
    ch_name = 'chanel_1';
end
