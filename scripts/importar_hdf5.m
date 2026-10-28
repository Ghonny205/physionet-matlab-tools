% Script para importar almacenamiento jerárquico HDF5 (.h5)
% Paso 1: Exploración de la jerarquía interna
h5disp('repositorio_multimodal_masivo.h5'); 

% Paso 2: Extracción del Dataset específico
ruta_nodo_interno = '/cohorte_a/sujeto_01/vector_electrocardiograma';
señal_extraida = h5read('repositorio_multimodal_masivo.h5', ruta_nodo_interno);
