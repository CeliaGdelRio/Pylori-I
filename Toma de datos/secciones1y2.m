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
writematrix(pos,'secciones1y2.xls','WriteMode','append');


header=["x_b","y_b","z_b","yaw_b","pitch_b","roll_b","x_e","y_e","z_e","yaw_e","pitch_e","roll_e","motores"];
writematrix(header,'secciones1y2.xls','WriteMode','append');

p1=1200;
p2=500;
for e=1:2 
    if e==1
       e1=1;
       e2=2;
   elseif e==2
       e1=2;
       e2=1;
   end
   motores(e1)=p1;
   motores(e2)=-p1;
   mover_motor(ardu,e2,2,1200,-1*p1,1);
   mover_motor(ardu,e1,2,1200,p1,1);
   for f=3:4 
       if f==3
           f1=3;
           f2=4;
       elseif f==4
           f1=4;
           f2=3;
       end
       motores(f1)=p1;
       motores(f2)=-p1;
       mover_motor(ardu,f2,2,1200,-1*p1,1);
       mover_motor(ardu,f1,2,1200,p1,1);
       for g=5:6
           if g==5
               g1=5;
               g2=6;
           elseif g==6
               g1=6;
               g2=5;
           end
           motores(g1)=p2;
           motores(g2)=-p2;
           mover_motor(ardu,g2,2,1200,-1*p2,1);
           mover_motor(ardu,g1,2,1200,p2,1);
          for h=7:8
              if h==7
                   h1=7;
                   h2=8;
               elseif h==8
                   h1=8;
                   h2=7;
               end
               motores(h1)=p;
               motores(h2)=-p;
               mover_motor(ardu,h2,2,1200,-1*p2,1);
               mover_motor(ardu,h1,2,1200,p2,1);
               basedata=receive(basesub,1);
               basepos=[basedata.pose.position.x,basedata.pose.position.y,basedata.pose.position.z,basedata.pose.orientation.x,basedata.pose.orientation.y,basedata.pose.orientation.z];
               extrdata=receive(extrsub,1);
               expos=[extrdata.pose.position.x,extrdata.pose.position.y,extrdata.pose.position.z,extrdata.pose.orientation.x,extrdata.pose.orientation.y,extrdata.pose.orientation.z];
               pos=[basepos,expos,motores];
               writematrix(pos,'secciones1y2.xls','WriteMode','append');
          end
       end
   end
end

calibrarRobot(ardu,2,1);
pause(2)
delete(ardu);