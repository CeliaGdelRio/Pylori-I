function mover_motor(motor,modo, pulsos)
% establecer conexion con arduino
    ardu=serialport("COM3",250000);
    pause(1);
    
    % configureTerminator(ardu,"CR")
    
    % set(Arduino,'DataBits',8);
    % set(Arduino,'StopBits',1);
    % set(Arduino,'Parity','none');
    % ardu.DataBits(8);
    % ardu.StopBits(1);
    % ardu.Parity('none');
    
    % modo en el que se va a mover
    if modo==0
        if motor==8
            i=17;
        elseif motor==6
            i=18;
        else
            i=motor;
        end
        vect="["+ i +";1;"+ pulsos +"]";
        writeline(ardu,vect);
        vect="["+i+";0]";
        pause(2);
        writeline(ardu,vect);
    end

delete(ardu);
end
