ardu=serialport("/dev/ttyACM0",115200);
calibrarRobot(ardu,0,1);

rosshutdown
rosinit("192.168.1.4",11311);
basesub=rossubscriber("/vrpn_client_node/Trackable1/pose","DataFormat","struct");
extrsub=rossubscriber("/vrpn_client_node/Trackable2/pose","DataFormat","struct");

%indico el origen
basedata=receive(basesub,0.5);
basepos=[basedata.pose.position.x,basedata.pose.position.y,basedata.pose.position.z,basedata.pose.orientation.x,basedata.pose.orientation.y,basedata.pose.orientation.z];
extrdata=receive(extrsub,0.5);
expos=[extrdata.pose.position.x,extrdata.pose.position.y,extrdata.pose.position.z,extrdata.pose.orientation.x,extrdata.pose.orientation.y,extrdata.pose.orientation.z];
% origen=["origen"];
% writematrix(origen,'dos_motores_2.xls','WriteMode','append');
motores=zeros(1,16);
pos=[basepos,expos,motores];
writematrix(pos,'dos_motores_6.xls','WriteMode','append');


header=["x_b","y_b","z_b","yaw_b","pitch_b","roll_b","x_e","y_e","z_e","yaw_e","pitch_e","roll_e","motores"];
writematrix(header,'dos_motores_6.xls','WriteMode','append');
% motores=zeros(1,16);
c=1;
ibis=1;
aux=1;

for i=ibis:3
    p=i*500;
    motores(14)=p;
    motores(13)=-1*p;
    mover_motor(ardu,14,2,1200,-1*p,1);
    mover_motor(ardu,13,2,1200,p,1);
%     disp(motores)

    for a=c:16
        if (a>14)
            if mod(a,2)==1
                a2=a+1;
            elseif mod(a,2)==0
                a2=a-1;
            end
            for b=aux:4
                p2=b*400;
                motores(a)=p2;
                motores(a2)=-1*p2;

                mover_motor(ardu,a2,2,1200,-1*p2,1);
                mover_motor(ardu,a,2,1200,p2,1);

                basedata=receive(basesub,1);
                basepos=[basedata.pose.position.x,basedata.pose.position.y,basedata.pose.position.z,basedata.pose.orientation.x,basedata.pose.orientation.y,basedata.pose.orientation.z];
                extrdata=receive(extrsub,1);
                expos=[extrdata.pose.position.x,extrdata.pose.position.y,extrdata.pose.position.z,extrdata.pose.orientation.x,extrdata.pose.orientation.y,extrdata.pose.orientation.z];
                pos=[basepos,expos,motores];
%                 disp(motores)
                writematrix(pos,'dos_motores_6.xls','WriteMode','append');
                %Lo devuelvo al origen despues de cada vez que lo muevo
                %calibrarRobot(ardu,2,1);
                motores(a)=0;
                motores(a2)=0;
            end
            aux=1;
            %Esto lo he añadido despues de generar dos_motores y
            %dos_motores_2.xls
            mover_motor(ardu,a2,2,1200,0,1);
            mover_motor(ardu,a,2,1200,0,1);
        end
    end
    c=1;
    motores(14)=0; 
    motores(13)=0;
end
ibis=1;

calibrarRobot(ardu,2,1);
delete(ardu);