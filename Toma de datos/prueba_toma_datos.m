ardu=serialport("/dev/ttyACM0",115200);
calibrarRobot(ardu,0,1);

rosshutdown
rosinit("192.168.1.4",11311);
basesub=rossubscriber("/vrpn_client_node/Trackable1/pose","DataFormat","struct");
extrsub=rossubscriber("/vrpn_client_node/Trackable2/pose","DataFormat","struct");

%indico el origen
basedata=receive(basesub,0.5);
basepos=[basedata.pose.position.x,basedata.pose.position.y,basedata.pose.position.z];
baseor= quat2eul([basedata.pose.orientation.x,basedata.pose.orientation.y,basedata.pose.orientation.z,basedata.pose.orientation.w]);
extrdata=receive(extrsub,0.5);
expos=[extrdata.pose.position.x,extrdata.pose.position.y,extrdata.pose.position.z];
exor=quat2eul([extrdata.pose.orientation.x,extrdata.pose.orientation.y,extrdata.pose.orientation.z,extrdata.pose.orientation.w]);
% % origen=["origen"];
% % writematrix(origen,'dos_motores_2.xls','WriteMode','append');
motores=zeros(1,16);
pos=[basepos,baseor,expos,exor,motores];
writematrix(pos,'un_motor.xls','WriteMode','append');

header=["x_b","y_b","z_b","yaw_b","pitch_b","w_b","roll_b","x_e","y_e","z_e","yaw_e","pitch_e","roll_e","w_e","motores"];
writematrix(header,'un_motor.xls','WriteMode','append');
motores=zeros(1,16);

for j=1:16
    motores=zeros(1,16);
    for i=1:5
        p=i*400;
        motores(j)=p;
        if mod(j,2)==1
            mover_motor(ardu,j+1,2,500,-1*p,1);
            mover_motor(ardu,j,2,500,p,1);
        elseif mod(j,2)==0
            mover_motor(ardu,j-1,2,500,-1*p,1);
            mover_motor(ardu,j,2,500,p,1);
        end
        basedata=receive(basesub,1);
        basepos=[basedata.pose.position.x,basedata.pose.position.y,basedata.pose.position.z];
        baseor= quat2eul([basedata.pose.orientation.x,basedata.pose.orientation.y,basedata.pose.orientation.z,basedata.pose.orientation.w]);
        extrdata=receive(extrsub,0.5);
        expos=[extrdata.pose.position.x,extrdata.pose.position.y,extrdata.pose.position.z];
        exor=quat2eul([extrdata.pose.orientation.x,extrdata.pose.orientation.y,extrdata.pose.orientation.z,extrdata.pose.orientation.w]);
        pos=[basepos,baseor,expos,exor,motores];
        writematrix(pos,'un_motor.xls','WriteMode','append');
    end
    calibrarRobot(ardu,2,j);
end
calibrarRobot(ardu,2,1);
delete(ardu);