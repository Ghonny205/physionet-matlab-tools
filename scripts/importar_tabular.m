% Script para importar archivos de texto plano (.csv, .txt)
% Procedimiento A: Importación de datos clínicos heterogéneos
datos_clinicos = readtable('registro_pacientes.csv');

% Procedimiento B: Importación de series temporales puramente numéricas
matriz_señal = readmatrix('serie_temporal_ecg.txt');
