% Script para importar estándar European Data Format (.edf)
% Fase 1: Extracción y evaluación de metadatos clínicos y técnicos
parametros_registro = edfinfo('estudio_polisomnografico.edf');
disp(parametros_registro.SignalLabels); 

% Fase 2: Carga de señales fisiológicas alineadas temporalmente
series_temporales = edfread('estudio_polisomnografico.edf');
