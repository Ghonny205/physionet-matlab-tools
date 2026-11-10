% 1. Leer el archivo CSV como tabla (ignorando cómo nombre a las cabeceras)
tabla_bidmc = readtable('bidmc_02_Signals.csv');

% 2. Extracción dinámica por posición de columna (Sin usar nombres explícitos)
% Asumimos que la columna 1 siempre es el tiempo, y la columna 2 es la señal a analizar
% Usamos {:, 1} para extraer los datos de la columna 1 sin importar cómo se llame
vector_tiempo = tabla_bidmc{:, 1}; 
canal_ecg = tabla_bidmc{:, 2};     

% Extraer los nombres originales de las columnas para usarlos como etiquetas automáticas
nombres_originales = tabla_bidmc.Properties.VariableNames;
nombre_eje_x = nombres_originales{1};
nombre_senal = nombres_originales{2};

