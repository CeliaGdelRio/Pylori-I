function moverRobot(ardu,newConfig,tray,N)
    % tray vale 1 si el robot debe seguir una trayectoria y 0 si no.
    % N es el número de puntos de la trayectoria.

if tray==1 % El robot debe llegar a la pos final pasando por los N puntos
    % de la trayectoria  
    for j=1:N
        % Se calculan los pulsos y la velocidad de los motores para cada
        % punto para mover los motores después
        fprintf('Punto nº %i\n', j);
        hilos = ang2long(newConfig{j});
        disp(hilos);
        [pulsos,vel] = long2pulsos(hilos);

        flush(ardu,"input");
        %motTensar=zeros(1,8);
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
    hilos = ang2long(newConfig{1});
    [pulsos,vel] = long2pulsos(hilos);

    flush(ardu,"input");% limpio los comandos que pudiese haber aún en arduino
    %se van a accionar primero los motores que se destensan y despues de
    %los que se tensan para no dañar la mecánica:
    tensar=zeros(1,8);%Variable que almacena que motores tensan
    cont=1;
        for i=1:2:16
            if hilos(i)<=0 %si el motor que se destensa es el impar
                m=i;
                writeline(ardu,"["+m+";2;"+vel(i)+";"+pulsos(i)+"]");%se mueve el motor impar
                pause(0.02)
                tensar(cont)=i+1; %almaceno en el vector de motores a tensar el par
            else %si el motor que se destensa es el par
                if i+1==8
                    m=17;
                elseif i+1==6
                    m=18;
                else
                    m=i+1;
                end
                writeline(ardu,"["+m+";2;"+vel(i+1)+";"+pulsos(i+1)+"]");%Se mueve el vector par
                pause(0.02)
                tensar(cont)=i+1; %almaceno en el vector de motores a tensar el impar
            end
            cont=cont+1;
        end
        pause(2);
end

pause(10);

% delete(ardu);
end
