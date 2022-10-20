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
writematrix(pos,'secciones3y4.xls','WriteMode','append');


header=["x_b","y_b","z_b","yaw_b","pitch_b","roll_b","x_e","y_e","z_e","yaw_e","pitch_e","roll_e","motores"];
writematrix(header,'secciones3y4.xls','WriteMode','append');

p=500;

for e=1:2 
    if e==1
       e1=1;
       e2=2;
   elseif e==2
       e1=2;
       e2=1;
   end
   motores(e1)=p;
   motores(e2)=-p;
   mover_motor(ardu,e2,2,1200,-1*p,1);
   mover_motor(ardu,e1,2,1200,p,1);
   for f=3:12 
       if f==3
           f1=3;
           f2=12;
       elseif f==12
           f1=12;
           f2=3;
       end
       motores(f1)=p;
       motores(f2)=-p;
       mover_motor(ardu,f2,2,1200,-1*p,1);
       mover_motor(ardu,f1,2,1200,p,1);
       for g=13:14
           if g==13
               g1=13;
               g2=14;
           elseif g==14
               g1=14;
               g2=13;
           end
           motores(g1)=p;
           motores(g2)=-p;
           mover_motor(ardu,g2,2,1200,-1*p,1);
           mover_motor(ardu,g1,2,1200,p,1);
          for h=15:16
              if h==15
                   h1=15;
                   h2=16;
               elseif h==16
                   h1=16;
                   h2=15;
               end
               motores(h1)=p;
               motores(h2)=-p;
               mover_motor(ardu,h2,2,1200,-1*p,1);
               mover_motor(ardu,h1,2,1200,p,1);
               basedata=receive(basesub,1);
               basepos=[basedata.pose.position.x,basedata.pose.position.y,basedata.pose.position.z,basedata.pose.orientation.x,basedata.pose.orientation.y,basedata.pose.orientation.z];
               extrdata=receive(extrsub,1);
               expos=[extrdata.pose.position.x,extrdata.pose.position.y,extrdata.pose.position.z,extrdata.pose.orientation.x,extrdata.pose.orientation.y,extrdata.pose.orientation.z];
               pos=[basepos,expos,motores];
               writematrix(pos,'secciones3y4.xls','WriteMode','append');
          end
       end
   end
end

calibrarRobot(ardu,2,1);
pause(2)
delete(ardu);