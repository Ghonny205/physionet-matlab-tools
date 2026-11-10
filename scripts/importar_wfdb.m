function [senal, tiempo] = abrir_wfdb(nombre_archivo)
    % 1. Leer el archivo binario
    fileID = fopen([nombre_archivo '.dat'], 'r');
    if fileID == -1
        error('No se encuentra el archivo .dat. Comprueba que el nombre sea correcto.');
    end
    datos = fread(fileID, [3, inf], 'uint8')';
    fclose(fileID);
    
    % 2. Desempaquetar los bits automáticamente (Formato 212)
    M1 = bitshift(bitand(datos(:, 2), 15), 8) + datos(:, 1);
    M2 = bitshift(bitshift(bitand(datos(:, 2), 240), -4), 8) + datos(:, 3);
    
    M1(M1 > 2047) = M1(M1 > 2047) - 4096;
    M2(M2 > 2047) = M2(M2 > 2047) - 4096;
    
    % 3. Convertir a valores físicos (Milivoltios)
    senal = [(M1 - 1024)/200, (M2 - 1024)/200];
    tiempo = (0:length(M1)-1)' / 360;
    
    % 4. Dibujar la gráfica 
    figure;
    plot(tiempo, senal(:, 1), 'b'); % Ahora plotea todas las muestras sin límite
    title(['Registro WFDB: ' nombre_archivo]);
    xlabel('Tiempo (Segundos)');
    ylabel('Amplitud (mV)');
    
    % Ajustar los ejes X e Y 
    axis tight; % Hace que el eje X empiece en 0 exacto y termine en el último segundo exacto
    
      ylim([min(senal(:,1)) - 0.5, max(senal(:,1)) + 0.5]); 
    
    grid on;
end
