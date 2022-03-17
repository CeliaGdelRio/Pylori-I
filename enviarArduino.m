function enviarArduino(Arduino,newConfig,tray,N)

% delete(instrfindall);
% Arduino = serial("COM5",'BaudRate',250000);
% 
% set(Arduino,'DataBits',8);
% set(Arduino,'StopBits',1);
% set(Arduino,'Parity','none');
% set(Arduino,'Timeout',0.5);
% fopen(Arduino);
% pause(2);

if tray == 1
    for j=1:N
        
        fprintf('Punto nº %i\n', j);
        hilos = ang2long(newConfig{j});
        [pulsos,vel] = long2pulsos(hilos);
        
        flushinput(Arduino);
        
        for i=1:16
           if i == 8
               b = "[17;2;"+vel(i)+";"+pulsos(i)+";]";
               fprintf(Arduino, '%s\n', b);
               pause(0.05);
           
           else
               b = "["+i+";2;"+vel(i)+";"+pulsos(i)+";]";
               fprintf(Arduino, '%s\n', b);
               pause(0.05);
           end

           Input_Text=fscanf(Arduino,'%s');
           disp(['Procesando: ' Input_Text]);

        end
        pause(2);
    end
    
else
    hilos = ang2long(newConfig)
    [pulsos,vel] = long2pulsos(hilos)

    flushinput(Arduino);

    for i=1:16
       if i == 8
           b = "[17;2;"+vel(i)+";"+pulsos(i)+";]";
           fprintf(Arduino, '%s\n', b);
           pause(0.05);
       else
           b = "["+i+";2;"+vel(i)+";"+pulsos(i)+";]";
           fprintf(Arduino, '%s\n', b);
           pause(0.05);
       end
       Input_Text=fscanf(Arduino,'%s');
       disp(['Procesando: ' Input_Text]);

    end
    
end



pause(10);

% % Volver al punto de partida para futuras coordenadas
% for i=1:16
%    b = "["+i+";2;"+vel(i)+";0;]";
%    fprintf(Arduino, '%s\n', b);
%    pause(0.05);
% end
% 

%fclose(Arduino);
end


            