ardu=serialport("/dev/ttyACM0",115200);
calibrarRobot(ardu,0,1);

rosshutdown
rosinit("192.168.1.4",11311);
basesub=rossubscriber("/vrpn_client_node/Trackable1/pose","DataFormat","struct");
extrsub=rossubscriber("/vrpn_client_node/Trackable2/pose","DataFormat","struct");

% %indico el origen
% basedata=receive(basesub,0.5);
% basepos=[basedata.pose.position.x,basedata.pose.position.y,basedata.pose.position.z];
% baseor= quat2eul([basedata.pose.orientation.x,basedata.pose.orientation.y,basedata.pose.orientation.z,basedata.pose.orientation.w]);
% extrdata=receive(extrsub,0.5);
% expos=[extrdata.pose.position.x,extrdata.pose.position.y,extrdata.pose.position.z];
% exor=quat2eul([extrdata.pose.orientation.x,extrdata.pose.orientation.y,extrdata.pose.orientation.z,extrdata.pose.orientation.w]);
% % % origen=["origen"];
% % % writematrix(origen,'dos_motores_2.xls','WriteMode','append');
% motores=zeros(1,16);
% pos=[basepos,baseor,expos,exor,motores];
% writematrix(pos,'dos_mot.xls','WriteMode','append');
% 
% header=["x_b","y_b","z_b","yaw_b","pitch_b","w_b","roll_b","x_e","y_e","z_e","yaw_e","pitch_e","roll_e","w_e","motores"];
% writematrix(header,'dos_mot.xls','WriteMode','append');
% motores=zeros(1,16);
c=13;
ibis=2;
aux=1;

for j=8:16
    motores=zeros(1,16);
    if mod(j,2)==1
        j2=j+1;
    elseif mod(j,2)==0
        j2=j-1;
    end
    for i=ibis:3
        p=i*400;
        motores(j)=p;
        motores(j2)=-1*p;
        mover_motor(ardu,j2,2,1200,-1*p,1);
        mover_motor(ardu,j,2,1200,p,1);

        
        for a=c:16
            if (a>j)&&(a>j2)
                if mod(a,2)==1
                    a2=a+1;
                elseif mod(a,2)==0
                    a2=a-1;
                end
                for b=aux:3
                    p2=b*400;
                    motores(a)=p2;
                    motores(a2)=-1*p2;
                    
%                     mover_motor(ardu,j2,2,1200,-1*p,1);
%                     mover_motor(ardu,j,2,1200,p,1);
                    
                    mover_motor(ardu,a2,2,1200,-1*p2,1);
                    mover_motor(ardu,a,2,1200,p2,1);
                    
                    basedata=receive(basesub,1);
                    basepos=[basedata.pose.position.x,basedata.pose.position.y,basedata.pose.position.z];
                    baseor= quat2eul([basedata.pose.orientation.x,basedata.pose.orientation.y,basedata.pose.orientation.z,basedata.pose.orientation.w]);
                    extrdata=receive(extrsub,0.5);
                    expos=[extrdata.pose.position.x,extrdata.pose.position.y,extrdata.pose.position.z];
                    exor=quat2eul([extrdata.pose.orientation.x,extrdata.pose.orientation.y,extrdata.pose.orientation.z,extrdata.pose.orientation.w]);
                    pos=[basepos,baseor,expos,exor,motores];
                    writematrix(pos,'dos_mot.xls','WriteMode','append');
                    %Lo devuelvo al origen despues de cada vez que lo muevo
                    %calibrarRobot(ardu,2,1);
                end
                aux=1;
                %Esto lo he añadido despues de generar dos_motores y
                %dos_motores_2.xls
                motores(a)=0; 
                motores(a2)=0;
                %Esto lo he eñadido despues de la últim ejecución
%                 mover_motor(ardu,a2,2,1200,0,1);
%                 mover_motor(ardu,a,2,1200,0,1);
            end
        end
        c=1;
        motores(j)=0; 
        motores(j2)=0;
    end
    ibis=1;
end
calibrarRobot(ardu,2,1);
delete(ardu);