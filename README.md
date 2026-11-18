elcome to the physionet-matlab-tools repository manual. This guide establishes a standardized, error-free protocol for importing biomedical signals from PhysioNet into the MATLAB environment.

Due to the obsolescence of legacy web conversion tools (such as PhysioBank ATM, which now returns a 404 Not Found error) and severe bugs found in native MATLAB functions and official toolboxes, this repository provides custom-built, low-level binary parsers. These tools abstract the complexity of medical data architectures, allowing students and researchers to focus strictly on signal processing.

Below is the comprehensive guide to using the custom functions provided in the /scripts directory for the four predominant biomedical formats.

1. Tabular Data (.csv, .txt)
Flat text files are commonly used for exported datasets or lightweight time series. The primary issue when importing these files into MATLAB is that clinical headers often contain spaces or special characters, which trigger syntax errors or alter the variable names upon import.

The Solution: The open_csv.m function uses positional matrix extraction (e.g., tbl{:, 1}) rather than explicit column names. This "blind" handling ensures that the time series and physiological amplitudes are successfully loaded into the Workspace regardless of the original header language or formatting.

Usage Example:

Matlab
% Load the tabular data bypassing header naming errors
[my_signal, my_time, ch_name] = open_csv('bidmc_01_Signals.csv');

% Plot the extracted signal
figure;
plot(my_time, my_signal, 'r');
title(['Signal: ', ch_name]);
xlabel('Time');
ylabel('Amplitude');
2. PhysioNet WFDB Architecture (.dat, .hea)
The WFDB format distributes patient records into binary data files (.dat) and plain-text headers (.hea). Attempting to use the official WFDB Toolbox on modern UNIX-based architectures (such as macOS M1/M2/M3 chips) often triggers a java.lang.UnsatisfiedLinkError because the OS blocks the underlying C++ code executed via the Java Virtual Machine.

The Solution: The abrir_wfdb.m function is a custom native decoder. It directly reads the raw bytes from the .dat file and unpacks PhysioNet's "Format 212" using bitwise masks and logical shifts, completely bypassing the incompatible Java environment.

Usage Example:

Matlab
% Extract the signal using the custom bit-decoder
% IMPORTANT: Always use a semicolon (;) at the end to prevent MATLAB from printing the massive data table in the Command Window
[signal, time] = abrir_wfdb('mit_bih_100');

% Plot the results
figure;
plot(time, signal(:, 1), 'b');
title('WFDB Import (No Java Required)');
3. Hierarchical Data Format 5 (.h5, .hdf5)
HDF5 files act as virtual file systems tailored for Big Data and machine learning datasets. A common roadblock for students is that advanced databases (like HeartCycle) pack the numeric data and text metadata together into Compound Datatypes (structs). If passed directly to the plot() function, MATLAB crashes with an "Invalid first data argument" error.

The Solution: The open_hdf5.m script provides an interactive graphical interface (uigetfile) to select the file. It features a "smart unpacking" algorithm that inspects the internal structure, isolates the pure numeric double array, and discards textual metadata, delivering clean variables ready for plotting.

Usage Example:

Matlab
% Calling the function empty opens an interactive file explorer
[my_signal, internal_path] = open_hdf5();

% The signal is unpacked and ready for mathematical operations
figure;
plot(my_signal);
title(['HDF5 Extracted Node: ', internal_path], 'Interpreter', 'none');
4. European Data Format (.edf / .edf+)
The EDF standard encapsulates both clinical metadata and continuous multi-channel signals. However, EDF+ files from PhysioNet (such as those in the EEG Motor Movement dataset) include textual annotation channels like "Record Time". Because MATLAB strictly forbids spaces in variable names, its native edfread function suffers a critical internal syntax crash (Error in line 243) when trying to parse the file.

The Solution: The abrir_edf.m script is a custom binary parser built from scratch. It opens the file at the byte level (int16), intelligently ignores any channels labeled "Annotation" or "Record", demultiplexes the matrix, and applies the physical scaling factors (gain and offset). This entirely circumvents MATLAB's broken native function.

Usage Example:

Matlab
% Extract the numeric physiological data, dodging the 'Record Time' bug
[sig, t, ch_name] = abrir_edf('S001R01.edf');

% Plot the decoded signal
figure;
plot(t, sig, 'g');
title(['Clean EDF+ Extracted Sensor: ', ch_name]);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
