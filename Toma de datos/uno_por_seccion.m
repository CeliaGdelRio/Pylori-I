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
% writematrix(pos,'unoxseccion_2.xls','WriteMode','append');
% 
% 
% header=["x_b","y_b","z_b","yaw_b","pitch_b","roll_b","x_e","y_e","z_e","yaw_e","pitch_e","roll_e","motores"]; 
% writematrix(header,'unoxseccion_2.xls','WriteMode','append');

p=400;
p1=800;
for a=1:4
   if a==1
       a1=1;
       a2=2;
   elseif a==2
       a1=2;
       a2=1;
   elseif a==3
       a1=3;
       a2=4;
   elseif a==4
       a1=3;
       a2=4;
   end
   motores(a1)=p;
   motores(a2)=-p;
   mover_motor(ardu,a2,2,1200,-1*p,1);
   mover_motor(ardu,a1,2,1200,p,1);
  
   for c=5:8       
      if c==5
           c1=5;
           c2=6;
       elseif a==6
           c1=6;
           c2=5;
      elseif c==7
           c1=7;
           c2=8;
       elseif a==8
           c1=8;
           c2=7;
       end
       motores(c1)=p;
       motores(c2)=-p;
       mover_motor(ardu,c2,2,1200,-1*p,1);
       mover_motor(ardu,c1,2,1200,p,1);
       
       for e=9:12 
           if e==9
              e1=9;
              e2=10;
           elseif e==10
              e1=10;
              e2=9;
           elseif e==11 
              e1=11;
              e2=12;
           elseif e==12
              e1=12;
              e2=11;
           end
           motores(e1)=p1;
           motores(e2)=-p1;
           mover_motor(ardu,e2,2,1200,-1*p1,1);
           mover_motor(ardu,e1,2,1200,p1,1);
           
           for g=13:16
               if g==13
                   g1=13;
                   g2=14;
               elseif g==14
                   g1=14;
                   g2=13;
               elseif g==15
                   g1=15;
                   g2=16;
               elseif g==16
                   g1=16;
                   g2=15;                       
               end
               motores(g1)=p1;
               motores(g2)=-p1;
               mover_motor(ardu,g2,2,1200,-1*p1,1);
               mover_motor(ardu,g1,2,1200,p1,1);
%                pause(0.4);

               basedata=receive(basesub,1);
               basepos=[basedata.pose.position.x,basedata.pose.position.y,basedata.pose.position.z];
               baseor= quat2eul([basedata.pose.orientation.x,basedata.pose.orientation.y,basedata.pose.orientation.z,basedata.pose.orientation.w]);
               extrdata=receive(extrsub,0.5);
               expos=[extrdata.pose.position.x,extrdata.pose.position.y,extrdata.pose.position.z];
               exor=quat2eul([extrdata.pose.orientation.x,extrdata.pose.orientation.y,extrdata.pose.orientation.z,extrdata.pose.orientation.w]);
               pos=[basepos,baseor,expos,exor,motores];
               writematrix(pos,'unoxseccion_2.xls','WriteMode','append');
               motores(13:16)=0;
               mover_motor(ardu,g2,2,1200,0,1);
               mover_motor(ardu,g1,2,1200,0,1);
           end
           motores(9:12)=0;
           mover_motor(ardu,e2,2,1200,0,1);
           mover_motor(ardu,e1,2,1200,0,1);
       end
        motores(5:8)=0;
        mover_motor(ardu,c2,2,1200,0,1);
        mover_motor(ardu,c1,2,1200,0,1);        
   end
   motores(1:4)=0;
   mover_motor(ardu,a2,2,1200,0,1);
   mover_motor(ardu,a1,2,1200,0,1);
end

calibrarRobot(ardu,2,1);
pause(2)
delete(ardu);