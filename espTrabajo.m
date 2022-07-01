function [N,n,v,b,r] = espTrabajo (obj, ikine)
    homeConfig = homeConfiguration(obj);
    obj.setConfig(homeConfig);
    
    N=2520; %1331;                                    %Puntos analizados de 4 en 4 cm
    n=0; v=0; b=0; r=0;
    percent=0;
    figure;
    obj.plot();
    hold on;
    
    for z=300:-40:-140
        for y=-240:40:280
            for x=-280:40:280
                targetPos = [x y z];
                tform = trvec2tform(targetPos);
                
                n=n+1;
                percent = (n/N)*100;
                
                switch ikine
                    case 1
                        [newConfig, error] = iKineGradientDescent(obj, tform);
                    case 2
                        [newConfig, error] = iKineJacobi(obj, tform);
                    case 3
                        [newConfig, error] = iKineHRR(obj, tform);
                end
                
                fprintf ('[%d %d %d] -- %d percent -- Error: %d\n', x, y, z, percent, error);
                
                if (error < 3.000001)
                    v=v+1;
                    plot3 (x,y,z,'g.','markersize',12);
                    hold on;
                elseif ((error > 3.000001) && (error <10.000001))
                    b=b+1;
                    plot3 (x,y,z, 'b.','markersize',12);
                    hold on;
                else
                    r=r+1;
                    plot3 (x,y,z, 'r.','markersize',12);
                    hold on;
                end
                
            end
        end
    end
    
    hold off;
    fprintf('\nDensidad de puntos verdes: %d percent\nDensidad de puntos azules: %d percent\nDensidad de puntos rojos: %d percent\n',(v/N)*100,(b/N)*100,(r/N)*100);

end