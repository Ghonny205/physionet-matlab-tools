% 1. Leer el .txt asumiendo que solo contiene matemáticas
matriz_datos = readmatrix('serie_temporal_ecg.txt');

% 2. Extracción por posición (Columna 1 y Columna 2)
vector_tiempo = matriz_datos(:, 1);
canal_senal = matriz_datos(:, 2);
