%% CREACIÓN DEL ROBOT:
    disp("Creando robot...");
    
    NLinks = [20 12 12 8];

    Assembly = {[0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0],
                [pi/2.0-2*pi/16 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0],
                [pi/2.0-2*pi/16 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0],
                [pi/2.0-2*pi/16 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0]};

    robot = HRRobot(NLinks, Assembly);
    
    disp("...OK");
%% ESPACIO DE TRABAJO
    disp("Generando espacio de trabajo...");
    delta = 25;  %Incremento longitudinal.
    deltaV = delta * delta * delta; %Diferencial de volumen.
    
    Zmin = -200;
    Zmax = 260;
    
    Xmin = -250;
    Xmax = 250;
    
    Ymin = -250;
    Ymax = 250;
    
    NX = cast((Xmax - Xmin)/delta, 'uint32');
    NY = cast((Ymax - Ymin)/delta, 'uint32');
    NZ = cast((Zmax - Zmin)/delta, 'uint32');
    disp("...OK");
    
    %Posición inicial del robot
    position = [0 50 150];
    tform = trvec2tform(position);
    [newConfig, error, ~] = robot.iKine(tform, 'Error', 0.1, 'MaxIter', 100);
    robot.setConfig(newConfig);
    disp("Robot situado en [X Y Z] = " + position(1) + ", " + position(2) + ", " + position(3) + " con un error de " + error);  
    
    disp("Generando mallado...");
    %Matriz de puntos del espacio
    M = zeros(NX, NY);
    for i = 1:NZ
       M = cat(3, M, zeros(NX, NY)); 
    end
    
    nx = getIndex(position(1), Xmin, delta);
    ny = getIndex(position(2), Ymin, delta);
    nz = getIndex(position(3), Zmin, delta);    
    M(nx, ny, nz) = 1;
    
    disp("OK");
%% RANDOM WALK
    disp("Calculando VOLUMEN DE TRABAJO...");
    % INICIO:        
        i = 0;
        maxIter = 10000;
        maxIterIKine = 100;
        maxError = 1;
        V = deltaV;
        
    % BUCLE PRINCIPAL:
    while i < maxIter
        %SALTO
        [nxp, nyp, nzp] = randomJump(nx, ny, nz, NX, NY, NZ, rng);
        
        %¿PUNTO YA COMPROBADO?
        if M(nxp, nyp, nzp) ~= 0
            %¿PUNTO VÁLIDO?
            if M(nxp, nyp, nzp) == 1
                %Si el punto es válido, se mueve a ese punto
                nx = nxp; ny = nyp; nz = nzp;                
            end            
        else
            %Punto no comprobado
                %COMPROBAR
                tform = trvec2tform([getCoord(nxp, Xmin, delta) getCoord(nyp, Ymin, delta) getCoord(nzp, Zmin, delta)]);
                %[newConfig, error, ~] = robot.iKine(tform, 'Error', maxError, 'MaxIter', maxIterIKine);
                error = 10;
                newConfig = robot.Config;
                ii = 0;
                while (error > 0.1)&&(ii < 20)                    
                    [newConfig, error, ~] = robot.iKineHRR(tform, 'InitConfig', newConfig);
                    ii = ii + 1;
                    if ii == 20
                        if error > maxError
                            ii = 20;
                        end
                    end
                end
                
                %¿PUNTO VÁLIDO?
                if error <= maxError
                    robot.setConfig(newConfig);
                    nx = nxp; ny = nyp; nz = nzp;
                    M(nx, ny, nz) = 1;
                    V = V + deltaV;
                else
                    M(nx, ny, nz) = 'x';
                end
        end
        
        i = i + 1;
        disp((i*100 / maxIter) + "%.........");
    end
    
    disp("VOLUMEN DE TRABAJO = " + V);
%% FUNCIONES AUXILIARES
function c = getCoord(n, min, delta)
    n = cast(n, 'double');
    min = cast(min, 'double');
    c = min + (n - 1) * delta;
end

function n = getIndex(c, min, delta)
    n = (c - min)/delta + 1;
    n = cast(n, 'uint32');
end

function [nx, ny, nz] = randomJump(nx, ny, nz, NX, NY, NZ, randomGen)
    rng(randomGen)
    nxp = nx + randi(3) - 2;
    
    while (nxp <= 0) || (nxp > NX)
        nxp = nx + randi(3) - 2;        
    end
    nx = nxp;    
    
    nyp = ny + randi(3) - 2;
    
    while (nyp <= 0) || (nyp > NY)
        nyp = ny + randi(3) - 2;        
    end
    ny = nyp;
    
    nzp = nz + randi(3) - 2;
    
    while (nzp <= 0) || (nzp > NZ)
        nzp = nz + randi(3) - 2;        
    end
    nz = nzp;
end
        
        
    

    
    


