function [pB,pE,motores]=transf_dat(ini,data) 
    %script para transformar los datos
    %valores con el robot en 0 para hallar la matriz de transformacion
        %los angulos los he pasado a Euler al tomarlos de ROS
%     ini=unoxseccion2;
%     data=unoxseccion1;
    b_ref_pos=ini(1:3);
    b_ref_or=ini(4:6);
    e_ref_pos=ini(7:9);
    e_ref_or=ini(10:12);   
    
    
    %hallo la matriz de transformacion
    MTH=transformador_optitrack(b_ref_pos',b_ref_or,e_ref_pos',e_ref_or);
    
    b_pos=data(:,1:3);
    b_or=data(:,4:6);
    e_or=data(:,10:12);
    e_pos=data(:,7:9);
    motores=data(:,13:28);
    
    
    %creo variables para los datos transformados
    pB=zeros(length(b_pos(:,1)),3);
    pE=zeros(length(b_pos(:,1)),3);
    
    for i=1:length(b_pos(:,1))
        b= MTH*[b_pos(i,:)';1];
        e= MTH*[e_pos(i,:)';1];
        pB(i,:)=b(1:3)';
        pE(i,:)=e(1:3)';
        if (pE(i,1)+pE(i,2)+pE(i,3))<10^-3
            aux=(pB(i,:));
            pB(i,:)=pE(i,:);
            pE(i,:)=aux;
        end
    end
toma=[pB,pE,motores];
writematrix(toma,'datos_NN.xls','WriteMode','append');

end
