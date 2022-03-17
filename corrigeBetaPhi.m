function [beta,phi] = corrigeBetaPhi(beta,phi)
%Corrección de ángulos
    %Signo de phi
    if phi < 0
        phi = 2*pi + phi; 
    end 

    %Signo de beta
    if beta < 0
        beta = -beta;
        phi = phi + pi;
    end

    %Mayores de 1 vuelta
    while (beta >= 2*pi)
        beta = beta - 2*pi;
    end
    
    while (phi >= 2*pi)
        phi = phi - 2*pi;
    end
end

