function calibrarRobot(modo,motor)
% establecer conexion con arduino
ardu=serialport("COM3",250000);
pause(1);

% configureTerminator(ardu,"CR")
flush(ardu,"input");

% como los motores 6 y 8 no estan conectados a sus respectivos drivers, 
% asignamos a m el valor necesario para mover el motor correcto
if motor==8
    m=17;
elseif motor==6
    m=18;
else
    m=motor;
end

% modo en el que se va a mover
    % modo 0: establece la posición actual del robot como la posición 0
    % modo 1: establece la posición de un motor como su posición 0
    % modo 2: RESET. Lleva el robot a su posición 0 a 500 pulsos/s
switch modo
    case 0
        for i=1:16
            if i==8
                vect="[17;3;0]";
            elseif i==6
                vect="[18;3;0]";
            else
                vect="["+i+";3;0]";
            end
        writeline(ardu,vect);
        pause(0.1);
        end
    case 1
        vect="["+m+";3;0]";
        writeline(ardu,vect);
        pause(0.05);
    case 2 
        for i=1:16
            if i==8
                vect="[17;2;500;0]";
            elseif i==6
                vect="[18;2;500;0]";
            else
                vect="["+i+";2;500;0]";
            end
            writeline(ardu,vect);
            pause(0.1);
        end
end
% Hay que borrar el objeto arduino antes de salir
delete(ardu);
end
