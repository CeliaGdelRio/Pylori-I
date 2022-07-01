function mover_motor(ardu,motor, modo, pulsos,pos,sec)
% % se establece conexion con arduino
% ardu=serialport("COM3",250000);
% pause(1);

% configureTerminator(ardu,"CR")
flush(ardu,"input");

% como los motores 6 y 8 no estan conectados a sus respectivos drivers, 
% asignamos a m el valor necesario para mover el motor correcto.
if motor==8
    m=17;
elseif motor==6
    m=18;
else
    m=motor;
end

% modo en el que se va a mover
    %modo 1: para mover un motor durante sec segundos
if modo==1
    vect="["+ m +";1;"+ pulsos +"]";
    writeline(ardu,vect);
    vect="["+m+";0]";
    pause(sec);
    writeline(ardu,vect);
    
    %modo 2: para mover un motor hasta la posición pos 
    % a la velocidad dada por pulsos 
elseif modo==2
   vect="["+ m +";2;"+ pulsos +";"+pos+"]";
   writeline(ardu,vect);
   pause(3);
end

% delete(ardu);
end
