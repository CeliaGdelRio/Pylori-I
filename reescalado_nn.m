function [y]=reescalado_nn(xmin,xmax,ymin,ymax,W1,W2,b1,b2,x)
%esta función reescala los datos para ejecutar la red y devuelve los
%resultados de la red ya deshecho el reescalado
xt=2*(x-xmin)./(xmax-xmin)-1;
xt=dlarray(xt);
yt=nn(xt,W1,W2,b1,b2);
yt=extractdata(yt);
yimp=((yt+1)/2).*(ymax-ymin)+ymin;
%tengo los motores impares, calculo tambien los pares
y=zeros(1,16);
for i=1:8
    y(i*2-1)= yimp(i);
    y(i*2)= -yimp(i);
end
end