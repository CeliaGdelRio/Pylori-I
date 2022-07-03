function [X,Y,Z] = calculateCircle(r, z, NPoints)
    q = cell(1, NPoints+1); %Vector de configuraciones.
    %Se calculan los puntos del círculo
    x1 = linspace(-r,r,NPoints/2+1);
    x2 = linspace(r,-r,NPoints/2+1);
    y1 = abs(sqrt(r^2-x1.^2));
    y2=-abs(sqrt(r^2-x2.^2));

    X=ones(1,NPoints+1);
    Y=ones(1,NPoints+1);
    Z=ones(1,NPoints+1)*z;
    for i = 1:(NPoints+1)
        if i<=NPoints/2
            X(i)=x1(i);
            Y(i)=y1(i); 
        else
            X(i)=x2(i-(NPoints/2));
            Y(i)=y2(i-(NPoints/2)); 
        end
    end
end