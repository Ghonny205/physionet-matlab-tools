% Script para importar arquitectura distribuida WFDB (.dat, .hea)
% Requiere WFDB Toolbox instalado. Omitir las extensiones (.dat, .hea).
identificador_registro = 'mit_bih_100'; 

% Invocación del algoritmo de lectura
[matriz_amplitudes, frecuencia_muestreo] = rdsamp(identificador_registro);
