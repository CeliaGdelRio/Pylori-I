function [yt]=nn(xt,W1,W2,b1,b2)
%esta funcion implementa la red neuronal a partir de los pesos (W1 y W2) y los
%sesgos (b1 y b2) obtenidos al entrenar la red en Python

%me aseguro de que mis parámetros tienen el formato que permite usar la
%función de activación ReLu
W1=dlarray(W1);
W2=dlarray(W2);
b1=dlarray(b1);
b2=dlarray(b2);
%obtengo la salida de la red
h=relu(W1'*xt+b1);
yt=W2'*h+b2;

end