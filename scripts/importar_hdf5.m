
% 1. Abrir ventana de selección de archivo
[nombre_archivo, ruta_carpeta] = uigetfile('*.h5', 'Selecciona el archivo biomédico HDF5');
if isequal(nombre_archivo, 0)
    error('Operación cancelada: No se ha seleccionado ningún archivo.');
end

ruta_completa = fullfile(ruta_carpeta, nombre_archivo);
fprintf('✅ Archivo detectado: %s\n', nombre_archivo);

% 2. Explorar y definir la ruta interna de los datos
info = h5info(ruta_completa);
ruta_interna = [info.Groups(1).Name, '/', info.Groups(1).Datasets(1).Name];

% 3. Extraer los datos en bruto
datos_brutos = h5read(ruta_completa, ruta_interna);

% 4. Desempaquetado inteligente (Por si los datos vienen en una estructura)
if isstruct(datos_brutos)
    campos = fieldnames(datos_brutos);
    datos_h5 = datos_brutos.(campos{1});
    
    if ~isnumeric(datos_h5) && length(campos) > 1
        datos_h5 = datos_brutos.(campos{2});
    end
else
    datos_h5 = datos_brutos;
end

% 5. Conversión a formato numérico estándar de MATLAB
datos_h5 = double(datos_h5);

fprintf('✅ Importación exitosa. Los datos están disponibles en la variable "datos_h5".\n');
