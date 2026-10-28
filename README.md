# Metodología de Importación y Estructuración de Señales Biomédicas en el Entorno de MATLAB

Para llevar a cabo el procesamiento digital de señales biomédicas procedentes del repositorio PhysioNet, resulta imperativo establecer un protocolo estandarizado de importación de datos. La diversidad de arquitecturas de almacenamiento empleadas en la investigación clínica exige la aplicación de funciones específicas dentro del entorno de ejecución de MATLAB para transferir eficientemente la información desde el almacenamiento físico hacia la memoria operativa del sistema, transformándola en variables matemáticas estructuradas.

A continuación, se detalla el procedimiento exhaustivo para la lectura y estructuración de los cuatro formatos de archivo predominantes en las bases de datos de instrumentación biomédica.

## 1. Archivos de Texto Delimitado y Tabulares (.csv, .txt)

Los formatos de texto plano separados por comas o tabulaciones representan una de las estructuras más primitivas pero universales en la exportación de datos. En el ámbito biomédico, se suelen emplear para conjuntos de datos preprocesados, series temporales unidimensionales o matrices de características extraídas. La importación de estos archivos requiere diferenciar si el contenido es puramente numérico o si posee una naturaleza heterogénea (combinación de cadenas de texto, identificadores y datos numéricos).

Para abordar su lectura en MATLAB, se emplean dos enfoques computacionales distintos:

* **Importación Estructurada (Datos Heterogéneos):** Cuando el archivo incluye cabeceras de columnas (por ejemplo, identificadores de pacientes, diagnósticos y valores de laboratorio), se debe utilizar la función `readtable`. Este comando analiza sintácticamente el archivo y construye una estructura de tipo tabla que preserva los nombres de las variables y admite múltiples tipos de datos en columnas adyacentes. Este enfoque es crucial para mantener la integridad de los metadatos clínicos.
* **Importación Numérica Pura (Señales Matemáticas):** Cuando el archivo contiene exclusivamente la amplitud de la señal muestreada, la función `readmatrix` es la herramienta óptima. A nivel computacional, esta función es significativamente más eficiente y rápida que `readtable`, ya que omite el análisis de caracteres y transfiere directamente los valores a un arreglo bidimensional numérico de precisión doble (matriz double). Este es el formato estrictamente necesario para aplicar operaciones de álgebra lineal o filtrado digital.

```matlab
% Procedimiento A: Importación de datos clínicos heterogéneos
% La función readtable preserva las cabeceras y estructura los datos
datos_clinicos = readtable('registro_pacientes.csv');

% Procedimiento B: Importación de series temporales puramente numéricas
% La función readmatrix genera directamente un arreglo matemático
matriz_señal = readmatrix('serie_temporal_ecg.txt');

```

## 2. Estándar European Data Format (.edf / .edf+)

El formato EDF es el estándar internacional por excelencia para el almacenamiento y transferencia de señales poligráficas, siendo omnipresente en estudios de electroencefalografía (EEG) y polisomnografía. Su principal ventaja arquitectónica radica en que encapsula dentro de un único archivo físico tanto los metadatos del paciente y del equipo de adquisición (cabecera) como las series temporales continuas multicanal.

La importación en MATLAB se realiza mediante un proceso en dos fases que garantiza una correcta gestión de la información, aprovechando las funciones nativas incorporadas en las versiones recientes del software:

* **Fase de Análisis de Cabecera:** Previo a la carga de datos masivos en la memoria, se invoca la función `edfinfo`. Esta rutina lee exclusivamente los primeros bytes del archivo para extraer la estructura organizativa: número de canales registrados, frecuencia de muestreo de cada canal (que puede ser asíncrona) y las etiquetas físicas de los electrodos. Esto permite validar la idoneidad del archivo antes de su procesamiento.
* **Fase de Carga y Alineación Temporal:** Posteriormente, la función `edfread` acomete la lectura de los datos fisiológicos. Dado que un archivo EDF puede contener señales muestreadas a distintas frecuencias (por ejemplo, un EEG a 256 Hz y la frecuencia respiratoria a 1 Hz), `edfread` vuelca la información en un objeto especializado denominado *timetable*. Esta estructura temporal alinea automáticamente todas las muestras en función de marcas de tiempo precisas, facilitando el análisis sincrónico multicanal.

```matlab
% Fase 1: Extracción y evaluación de metadatos clínicos y técnicos
parametros_registro = edfinfo('estudio_polisomnografico.edf');
disp(parametros_registro.SignalLabels); % Verificación de electrodos

% Fase 2: Carga de señales fisiológicas alineadas temporalmente
% Genera un objeto de series temporales para su análisis continuo
series_temporales = edfread('estudio_polisomnografico.edf');

```

## 3. Arquitectura Distribuida WFDB de PhysioNet (.dat, .hea)

La familia de formatos WFDB (Waveform Database) constituye la columna vertebral del repositorio PhysioNet. A diferencia de estándares encapsulados como el EDF, WFDB emplea una arquitectura distribuida donde un único registro médico se fragmenta en múltiples componentes dependientes. El archivo `.dat` contiene las muestras numéricas bajo algoritmos de compresión binaria específicos (como el formato 212 de PhysioNet), los cuales son ininteligibles por sí solos. La clave de decodificación, así como las ganancias de los sensores y la frecuencia de muestreo, residen en un archivo de texto plano complementario con extensión `.hea` (Header).

Para la correcta importación en MATLAB, es un prerrequisito indispensable que ambos archivos converjan en el mismo directorio. La metodología requiere el uso de herramientas específicas que automaticen la lectura de la cabecera, la descompresión binaria y el escalado de los datos:

* **Proceso de Decodificación Integral:** Se emplea la función `rdsamp`, perteneciente a las librerías oficiales de PhysioNet para MATLAB (WFDB Toolbox). Al proporcionar únicamente la raíz del nombre del registro (omitiendo explícitamente cualquier extensión), el algoritmo busca autónomamente el archivo `.hea`, interpreta sus instrucciones de formato y, a continuación, lee el archivo `.dat` correspondiente.
* **Retorno de Datos:** La función transfiere a la memoria operativa una matriz numérica bidimensional donde cada columna representa un canal fisiológico (ya convertido a sus unidades físicas reales, como milivoltios), junto con un valor escalar que define la frecuencia de muestreo del hardware utilizado en la adquisición.

```matlab
% Definición del identificador del registro médico
% Es imperativo omitir las extensiones (.dat, .hea) en este argumento
identificador_registro = 'mit_bih_100'; 

% Invocación del algoritmo de lectura y descompresión bidireccional
% Retorna la amplitud de las señales (matriz) y su frecuencia de muestreo (escalar)
[matriz_amplitudes, frecuencia_muestreo] = rdsamp(identificador_registro);

```

## 4. Estructuras de Almacenamiento Jerárquico HDF5 (.h5, .hdf5)

En el paradigma contemporáneo de datos masivos (Big Data) en la investigación biomédica, los archivos HDF5 (Hierarchical Data Format versión 5) son utilizados para almacenar registros de altísima resolución espacial y temporal. Su diseño interno difiere radicalmente de un archivo plano; actúa como un sistema de ficheros virtual autónomo, compuesto por agrupaciones jerárquicas (Groups) y conjuntos de datos (Datasets). Esto permite almacenar gigabytes de señales multicanal sin comprometer la eficiencia del sistema.

La manipulación de archivos HDF5 en MATLAB requiere un enfoque de navegación estructural, similar a explorar los directorios de un sistema operativo, para extraer selectivamente la información:

* **Inspección Topológica del Archivo:** Debido a que el usuario habitualmente desconoce la taxonomía interna con la que fue creado el archivo, el primer paso riguroso es emplear la función `h5disp`. Este comando imprime en la consola de comandos el árbol completo de la arquitectura del archivo, revelando las rutas absolutas donde residen los datos numéricos (por ejemplo, `/Paciente_01/Señales/ECG_Lead_I`).
* **Extracción de Vectores de Datos:** Una vez identificada la ruta exacta del *Dataset* de interés, se recurre a la función `h5read`. Esta rutina accede directamente al nodo específico dentro del archivo HDF5 y carga su contenido en la memoria como una matriz matemática multidimensional. Esta aproximación selectiva previene el desbordamiento de la memoria del ordenador, ya que evita la carga de la totalidad de las variables contenidas en el repositorio HDF5.

```matlab
% Paso 1: Exploración de la jerarquía interna del repositorio
% Esta función expone la topología de carpetas virtuales del archivo
h5disp('repositorio_multimodal_masivo.h5'); 

% Paso 2: Localización y extracción del Dataset específico
% Se define la ruta interna exacta descubierta en el paso anterior
ruta_nodo_interno = '/cohorte_a/sujeto_01/vector_electrocardiograma';

% Paso 3: Volcado de la información en una variable operativa
señal_extraida = h5read('repositorio_multimodal_masivo.h5', ruta_nodo_interno);

```
