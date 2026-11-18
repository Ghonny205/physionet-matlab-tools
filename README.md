# PhysioNet MATLAB Tools:  Import Manual

 This project establishes a method, error-free protocol for importing biomedical signals from PhysioNet into the MATLAB environment.

Due to the obsolescence of legacy web conversion tools (such as PhysioBank ATM, which now returns a `404 Not Found` error) and severe bugs found in native MATLAB functions and official toolboxes, this repository provides the solution. Allowing students and researchers to focus strictly on signal processing without dealing with configuration errors.

Below is the comprehensive guide to using the custom functions provided in the `/scripts` directory for the four predominant biomedical formats.

---

## 1. Tabular Data (.csv, .txt)

Flat text files are commonly used for exported datasets or lightweight time series. The primary issue when importing these files into MATLAB is that clinical headers often contain spaces or special characters, which trigger `VariableNamingRule` syntax errors or alter the variable names upon import.

**The Solution:** The `open_csv.m` function uses positional matrix extraction, rather than explicit column names. This "blind" handling ensures that the time series and physiological amplitudes are successfully loaded into the Workspace regardless of the original header language or formatting.

### Usage Example:

```matlab
% Load the tabular data bypassing header naming errors
[my_signal, my_time, ch_name] = open_csv('bidmc_01_Signals.csv');

% Plot the extracted signal
figure;
plot(my_time, my_signal, 'r');
title(['Signal: ', ch_name], 'Interpreter', 'none');
xlabel('Time');
ylabel('Amplitude');
```

---

## 2. PhysioNet WFDB Architecture (.dat, .hea)

The WFDB format distributes patient records into binary data files (`.dat`) and plain-text headers (`.hea`).

**Known Issue:** Attempting to use the official WFDB Toolbox on modern UNIX-based architectures (such as macOS M1/M2/M3 chips) often triggers a `java.lang.UnsatisfiedLinkError`. This happens because the operating system blocks the underlying C++ code executed via the Java Virtual Machine.

**The Solution:** The `abrir_wfdb.m` function is a custom native decoder. It directly reads the raw bytes from the `.dat` file and unpacks PhysioNet's "Format 212" using bitwise masks and logical shifts.

### Usage Example:

```matlab
% Extract the signal using the custom bit-decoder
% IMPORTANT: Always use a semicolon (;) at the end to prevent MATLAB from printing the massive data table
[signal, time] = abrir_wfdb('mit_bih_100');

% Plot the results
figure;
plot(time, signal(:, 1), 'b');
title('WFDB Import (No Java Required)');
xlabel('Time (Seconds)');
ylabel('Amplitude (mV)');
axis tight;
```

---

## 3. Hierarchical Data Format 5 (.h5, .hdf5)

HDF5 files act as virtual file systems tailored for Big Data and machine learning datasets. A common roadblock for students is that advanced databases (like *HeartCycle*) pack the numeric data and text metadata together into Compound Datatypes (`structs`). If passed directly to the `plot()` function, MATLAB crashes with an *Invalid first data argument* error.

**The Solution:** The `open_hdf5.m` script provides an interactive graphical interface (`uigetfile`) to select the file. Isolates the pure numeric `double` array, and discards textual metadata, delivering clean variables ready for mathematical operations.

### Usage Example:

```matlab
% Calling the function empty opens an interactive file explorer
[my_signal, internal_path] = open_hdf5();

% The signal is unpacked and ready for plotting
figure;
plot(my_signal);
title(['HDF5 Extracted Node: ', internal_path], 'Interpreter', 'none');
xlabel('Samples');
ylabel('Amplitude');
```

---

## 4. European Data Format (.edf / .edf+)

The EDF standard encapsulates both clinical metadata and continuous multi-channel signals in a single file.

**Known MATLAB Bug:** EDF+ files from PhysioNet include textual annotation channels like "Record Time". Because MATLAB strictly forbids spaces in variable names, its native `edfread` function suffers a critical internal syntax crash when trying to parse the file.

**The Solution:** The `open_edf.m` script is a custom binary parser built from scratch. It opens the file at the byte level (`int16`),searches for and ignores any channels labeled "Annotation" or "Record", demultiplexes the matrix, and applies the physical scaling factors (gain and offset). This entirely circumvents MATLAB's broken native function.

### Usage Example:

```matlab
% Extract the numeric physiological data, dodging the native 'Record Time' bug
[sig, t, ch_name] = open_edf('S001R01.edf');

% Plot the decoded signal
figure;
plot(t, sig, 'g');
title(['Clean EDF+ Extracted Sensor: ', ch_name], 'Interpreter', 'none');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
axis tight;
```
