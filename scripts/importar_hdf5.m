function [data, internal_path] = open_hdf5(filename)
% Load HDF5 biomedical files with smart unpacking for structs

% Open UI if no file is provided
if nargin < 1 || isempty(filename)
    [file, path] = uigetfile('*.h5', 'Select HDF5 biomedical file');
    if isequal(file, 0)
        error('Operation canceled: No file selected.');
    end
    filename = fullfile(path, file);
end

% Get file info and default to the first group/dataset
info = h5info(filename);
internal_path = [info.Groups(1).Name, '/', info.Groups(1).Datasets(1).Name];

% Read raw data
raw_data = h5read(filename, internal_path);

% Smart unpacking if data is wrapped in a struct (e.g. HeartCycle DB)
if isstruct(raw_data)
    fields = fieldnames(raw_data);
    data = raw_data.(fields{1});

    % If first field is text (units, metadata), try the second one
    if ~isnumeric(data) && length(fields) > 1
        data = raw_data.(fields{2});
    end
else
    data = raw_data;
end

% Force standard numeric format
data = double(data);
end
