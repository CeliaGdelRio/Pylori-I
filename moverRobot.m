function moverRobot(newConfig,tray,N)

% establecer conexion con arduino
ardu=serialport("COM3",250000);
pause(1);

    % tray vale 1 si el robot debe seguir una trayectoria y 0 si no.
    % N es el número de puntos de la trayectoria.

if tray == 1 % El robot debe llegar a la pos final pasando por los N puntos
    % de la trayectoria  
    for j=1:N
        % Se calculan los pulsos y la velocidad de los motores para cada
        % punto para mover los motores después
        fprintf('Punto nº %i\n', j);
        hilos = ang2long(newConfig{j});
        [pulsos,vel] = long2pulsos(hilos);

        flush(ardu,"input");
        for i=1:16
            if i==8
                m=17;
            elseif i==6
                m=18;
            else
                m=i;
            end
            writeline(ardu,"["+m+";2;"+vel(i)+";"+pulsos(i)+"]");
            pause(0.05)
        end
        pause(2);
    end

else % si no se sigue una trayectoria, se mueven los motores directamente

    %Se calculan los valores de velocidad y pulsos para mover cada motor
    hilos = ang2long(newConfig);
    [pulsos,vel] = long2pulsos(hilos);

    flush(ardu,"input");
        for i=1:16
            if i==8
                m=17;
            elseif i==6
                m=18;
            else
                m=i;
            end
            writeline(ardu,"["+m+";2;"+vel(i)+";"+pulsos(i)+"]");
            pause(0.05)
        end
        pause(2);
end

pause(10);

delete(ardu);
end
