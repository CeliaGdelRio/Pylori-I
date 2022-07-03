logService('TRACE', "Volumen de Trabajo - Montecarlo");
logService('TRACE', "_______________________________");

%% CREACIÓN DEL ROBOT
    logService('DEBUG', "Creado robot...");

    nLinks = [19 12 10 9];
    alfas = pi/2*ones(1, length(nLinks));
    robot = HRRobot(nLinks, alfas);

    logService('DEBUG', "... robot creado.");

%% INICIALIZACIONES
    logService('DEBUG', "Inicializando variables...");
    
    robotLength = robot.TotalLinks*5;
    
    nX = 60;
    nY = 1;
    nZ = 120;
    %nPoints = nX*nY*nZ;
    nPoints = 1000;
    nSuccess = 0;
    nFailed = 0;
    
    xMax = 3*robotLength/2;
    xMin = 0;
    x = linspace(xMin, xMax, nX);
    
    %yMax = 3*robotLength/2;
    yMax = 1;
    yMin = -yMax;
    y = linspace(yMin, yMax, nY);
    
    zMax = robotLength;
    zMin = -robotLength/2;
    z = linspace(zMin, zMax, nZ);
    
    x0 = xMax/2;
    y0 = yMax/2;
    z0 = zMax/2;
    
    v = abs((xMax-xMin)*(yMax-yMin)*(zMax-zMin));
    
    logService('DEBUG', "... variables inicializadas.");
    
%%  BUCLE PRINCIPAL
    rngSeed = rng('shuffle');
    
    successPoints = cell(nPoints, 1);
    failedPoints = cell(nPoints, 1);
    manipulabilities = zeros(nPoints, 1);
    parfor i = 1:nPoints
        %Generación de un punto aleatorio
        %rngSeed = rng(rngSeed);
        p = 2*rand(1,3)-1;
        p(1) = (p(1)+1)*xMax/2;
        p(2) = p(2)*yMax;
        p(3) = p(3)*zMax;
        
        %Cálculo de un primer punto de aproximación
        q = p;
        if p(1)>=0
            q(1) = x0;
        else
            q(1) = -x0;
        end
        
        if p(2)>=0
            q(2) = y0;
        else
            q(2) = -y0;
        end
        
        if p(3)>=0
            q(3) = z0;
        else
            q(3) = -z0;
        end
        
        %Posicionamiento hacia el primer punto
        robot.resetConfig();
        robot.move(q(1), q(2), q(3), 'GradientDescent','Error', 1);
        
        %Posicionamiento hacia el punto alatorio
        [~, e, ~] = robot.move(p(1), p(2), p(3), 'Default','Error', 1);
        if e{1}<=1
            nSuccess = nSuccess + 1;
            successPoints{i, 1}=p;
            manipulabilities(i, 1)=manipulability(robot.jacobianHRR());
            logService('INFO', "¡Punto " + p(1) + "," + p(2) + "," + p(3) + " alcanzado!");
        else
            nFailed = nFailed + 1;
            failedPoints{i, 1}=p;
            %logService('INFO', "Punto " + p(1) + "," + p(2) + "," + p(3) + " no alcanzado");
        end
        %%progress = 100*(i/nPoints);
        %%logService('INFO', "Progress..." + progress + "%");
    end

vW = (nSuccess/nPoints)*v;
logService('INFO', "Volumen de trabajo estimado:");
logService('INFO', vW);
logService('INFO', "(" + vW/v*100 + "%)");

xs = zeros(1,length(successPoints));
ys = xs;
zs = xs;

xf = xs;
yf = xs;
zf = xs;

for i = 1:length(successPoints)
    xs(i)=successPoints{i}(1);
    ys(i)=successPoints{i}(2);
    zs(i)=successPoints{i}(3);
end

for i = 1:length(failedPoints)
    xf(i)=failedPoints{i}(1);
    yf(i)=failedPoints{i}(2);
    zf(i)=failedPoints{i}(3);
end

scatter3(xs, ys, zs, 'ob', 'filled');
hold on;
scatter3(xf, yf, zf, 'or', 'filled');
axis equal;