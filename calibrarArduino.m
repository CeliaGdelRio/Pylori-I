function calibrarArduino(Arduino,modo,motor,pul)

% INICIAR ARDUINO
delete(instrfindall);
Arduino = serialport("COM3",250000);

% Arduino.DataBits(8);
% Arduino.StopBits(1);
% Arduino.Parity('none');
% Arduino.Timeout(1);
set(Arduino,'DataBits',8);
set(Arduino,'StopBits',1);
set(Arduino,'Parity','none');
set(Arduino,'Timeout',0.5);
% %configureTerminator(Arduino,"CR/LF");
fopen(Arduino);
% pause(2);


switch modo
    
    % Establecer posicion actual en 0 antes de calibrar
    case 0
        flushinput(Arduino);
        for i=1:16
            if i==8                                     % Hecho porque el enchufe 8 no funciona
                b = "[18;3;0;]";                        % Eliminar en caso contrario
                fprintf(Arduino, '%s\n', b);
                pause(0.05);
            
            else
                b = "["+i+";3;0;]";
                fprintf(Arduino, '%s\n', b);
                pause(0.05);
            end
            
            Input_Text=fscanf(Arduino,'%s');
            disp(['Inicializando: ' Input_Text]);
            
        end

    % Calibrar
    case 1
        flushinput(Arduino);
        if motor == 8                                     % Hecho porque el enchufe 8 no funciona
            b = "[18;2;150;"+pul+";]";                    % Eliminar en caso contrario
            fprintf(Arduino, '%s\n', b);
            pause(0.05);
            
        else
            b = "["+motor+";2;150;"+pul+";]";
            fprintf(Arduino, '%s\n', b);
            pause(0.05);
        end
        
        Input_Text=fscanf(Arduino,'%s');
        disp(['Calibrando: ' Input_Text]);
        
    % Fijar el cero del motor
    case 2
        flushinput(Arduino);
        if motor == 8                                     % Hecho porque el enchufe 8 no funciona
            b = "[18;3;0;]";                              % Eliminar en caso contrario
            fprintf(Arduino, '%s\n', b);
            pause(0.05);
            
        else
            b = "["+motor+";3;0;]";
            fprintf(Arduino, '%s\n', b);
            pause(0.05);
        end
        
        Input_Text=fscanf(Arduino,'%s');
        disp(['Fijando: ' Input_Text]);
       
    % RESET    
    case 3
        flushinput(Arduino);
        for i=1:16
            if i == 8                                         % Hecho porque el enchufe 8 no funciona
                b = "[18;3;0;]";                              % Eliminar en caso contrario
                fprintf(Arduino, '%s\n', b);
                pause(0.05);
            
            else
                b = "["+i+";2;150;0;]";
                fprintf(Arduino, '%s\n', b);
                pause(0.05);
            end
        end
end