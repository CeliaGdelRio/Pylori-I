function [pulsos,vel] = long2pulsos(hilos)
    % 1600 pulsos/rev
    % 28,27 mm/rev
    % ~~57 pulsos/mm
    % Movimiento en un máximo de 3 sec
    
    for i=1:16
        pulsos(i)= 57*hilos(i);
        vel(i)=abs(pulsos(i))/3;
    end    
end

