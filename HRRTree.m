classdef HRRTree < rigidBodyTree
    %HRROBOT Objeto Robot Hiperredundante.
    
    properties
        NSections;  %Número de secciones
        NLinks; %Número de discos en cada sección
        TotalLinks; %Número total de discos
        
        Assembly;
        Alpha;
        EndLink;
        A;
        Config;
    end
    
    methods (Access = public)
        %% CONSTRUCTOR
        function obj = HRRTree(NLinks, Alpha)
            %Previous calculations:
            obj.NSections = length(NLinks);
            obj.NLinks = NLinks;
            obj.TotalLinks = 0;
            for i = 1:obj.NSections
                obj.TotalLinks = obj.TotalLinks + obj.NLinks(i);
            end
            
            obj.Alpha = Alpha;
            obj.createSections();
            obj.EndLink = obj.BodyNames{obj.NumBodies};
            obj.Config = homeConfiguration(obj);
        end
        
        %% SECTION IKINE
        function jointPositions = sectionIKine(obj, index, coords, type)
            %Inicializaciones   
            nLinks = obj.NLinks(index);   %Se inicializa elnúmero de discos
    
            beta = 0;
            phi = 0;
            r = 0;
            
            switch type
                case 'cart'
                    coords = cart2sph(coords);
                    [beta, phi, r] = sph2hrr(coords);
                case 'sph'
                    [beta, phi, r] = sph2hrr(coords);
                case 'hrr'
                    beta = coords(1);
                    phi = coords(2);
                    r = coords(3);
            end
            
            [beta, phi] = corrigeBetaPhi(beta, phi);
            
            %__________________________________________________________________________    
            %   PRIMERA SOLUCIÓN

            %Término independiente
            b = [cos(phi) sin(phi)]' * beta;
            
            %Matrices del sistema
            if index == 1
                M = obj.A{index}(:, 2:nLinks);
            else                        
                M = obj.A{index};
            end
            
            MMT = M * M';    
         
            if rcond(MMT) < 1e-20
                %logService('WARN', 'Matriz mal condicionada');
                jointPositions = config2joints(obj.Config);
            else 
                %Resolución del sistema
                z = linsolve(MMT, b);
                x = M' * z;              
                if index == 1
                    jointPositions = zeros(length(x) + 1, 1);
                    jointPositions(1,1) = 0;
                    jointPositions(2:length(x) + 1, 1) = x(1:length(x)); 
                else                             
                    jointPositions(1:length(x)) = x(1:length(x));
                end
            end
        end
        
        %% SECTION IKINE2
        function jointPositions = sectionIKine2(obj, index, coords, type)
            %Constantes
            emax = 0.001; %Error permitido
            k = 0.001; %Constante de corrección
            c = 0;  %contador de iteraciones
            cmax = 10000; %Máximo de iteraciones

            %Inicializaciones   
            nLinks = obj.NLinks(index);   %Se inicializa elnúmero de discos
    
            beta = 0;
            phi = 0;
            r = 0;
            
            switch type
                case 'cart'
                    coords = cart2sph(coords);
                    [beta, phi, r] = sph2hrr(coords);
                case 'sph'
                    [beta, phi, r] = sph2hrr(coords);
                case 'hrr'
                    beta = coords(1);
                    phi = coords(2);
                    r = coords(3);
            end
            
            [beta, phi] = corrigeBetaPhi(beta, phi);
            
            %__________________________________________________________________________    
            %   PRIMERA SOLUCIÓN

            %Término independiente
            b = [cos(phi) sin(phi)]' * beta;
            
            %Matrices del sistema
            if index == 1
                M = obj.A{index}(:, 2:nLinks);
            else                        
                M = obj.A{index};
            end
            
            MMT = M * M';
            
            %Resolución del sistema
            z = linsolve(MMT, b);
            x = M' * z;
            
            if index == 1
                jointPositions = zeros(length(x) + 1, 1);
                jointPositions(1,1) = 0;
                jointPositions(2:length(x) + 1, 1) = x(1:length(x)); 
            else                        
                jointPositions(1:length(x)) = x(1:length(x));
            end
            
            x2 = zeros(1, length(x));    
            xe2 = zeros(1, length(x));
            
            %Cálculo de la posición lograda
            config = homeConfiguration(obj);
            [config] = obj.changeSectionConfig(index, jointPositions, 'RobotConfig', config);
            [betas, phis] = obj.angulosSecciones(config2joints(config));
            beta2 = betas(index);
            phi2 = phis(index);
            %__________________________________________________________________________
            %	MÉTODO ITERATIVO: solución final

            while (((abs(beta2-beta) > emax) && (abs(phi2-phi) > emax)) && ( c < cmax ))
            %Nuevo término independiente
                b = [cos(phi2) sin(phi2)]'*beta2;

            %Se resuelve el sistema
                z = linsolve(MMt,b);
                xe = Mt*z;
                xe2(2:nLinks) = xe;

            %Se aplica la corrección
                x2 = x2 - (xe2 - x2)*k;
                                  
                jointPositions(1:length(x2)) = x2(1:length(x2));

            %Cálculo de la posición lograda
                config = homeConfiguration(obj);
                [config] = obj.changeSectionConfig(index, joints2config, 'RobotConfig', config);
                [betas, phis] = obj.angulosSecciones(config2joints(config));
                beta2 = betas(index);
                phi2 = phis(index);

                c=c+1;
            end
        end
        
        %% FKINE
        function endEffectorTransform = fKine(obj, config)
            endEffectorTransform = getTransform(obj, config, obj.EndLink);
        end
        
        %% CURRENT POSITION
        function cp = currentPos(obj)
           cp = tform2trvec(obj.fKine(obj.Config));
        end
        %% IKINE
        function [newConfig, e, iterTot] = iKine(obj, tform, varargin)
            %Inicializaciones:
            ef = 0.1;
            iterMax = 20;
            iterTotMax = 2*iterMax;
            newConfig = obj.Config;
            
            for i = 1:2:length(varargin)
                switch varargin{i}
                    case 'Error'
                       ef = varargin{i+1};
                       
                    case 'InitConfig'
                       newConfig = varargin{i+1};
                end
            end
            
            e = ef + 1;
            
            iter = 0;
            iterTot = 0;
            
            %Ajuste a solución aproximada
            while (e > 10*ef)&&(iter < iterMax)
                [newConfig, e, ~] = obj.iKineJacobi(tform, 'InitConfig', newConfig);
                iter = iter + 1;
                iterTot = iterTot + 1;
            end
            
            iter = 0;
            %Ajuste Cinemático
            while (iter == 0)||((e > ef)&&(iter < iterMax)&&(iterTot < iterTotMax))
                [newConfig, e, ~] = obj.iKineHRR(tform, 'InitConfig', newConfig);
                iter = iter + 1;
                iterTot = iterTot + 1;
            end
        end
        
        %% IKINE GRADIENT DESCENT
        function [newConfig, e, iter] = iKineGradientDescent(obj, tform, varargin)
            logService('DEBUG', 'INI - ikineGradientDescent');
            
            %INICIALIZACIONES:
            currentConfig = obj.Config;
            
            iter = 0;      %Contador de iteraciones.
            maxIter = 50; %Máximo de iteraciones.
            
            ef = 0.1;   %Error deseado
            k = 1;      %Constante de correcion
            
            m = 50;             %Iteración de convergecia
            epsilon = 10 * ef;  %Valor de convergencia 
            
            de_Beta = zeros(obj.NSections, 1);  %Diferencial de error en función de Beta
            de_Phi = zeros(obj.NSections, 1);   %Diferencial de error en función de Phi
            
            for i = 1:2:length(varargin)
                switch varargin{i}
                    case 'Error'
                       ef = varargin{i+1};
                       
                    case 'MaxIter'
                       maxIter = varargin{i+1};
                       
                    case 'k'
                       k = varargin{i+1};
                       
                    case 'InitConfig'
                       currentConfig = varargin{i+1};
                       
                    case 'm'
                       m = varargin{i+1};
                       
                    case 'epsilon'
                       epsilon = varargin{i+1};
                end
            end
            
            newConfig = currentConfig;
            
            %Saves initial values
            [beta, phi] = obj.angulosSecciones(config2joints(currentConfig));
            
            targetPos = tform2trvec(tform);
            currentPos = tform2trvec(obj.fKine(currentConfig));
            
            e = norm(currentPos - targetPos);   %Error   
            
            while  (e > ef) && (iter < maxIter)
           %CÁLCULO DE BETA Y PHI:
                   firstLink = 0;
                   lastLink = 0;
               for i = 1:obj.NSections                   
                   firstLink = lastLink + 1;
                   lastLink = firstLink + obj.NLinks(i)-1;
                   %de_Beta:
                       %Cálculo de la nueva configuracion para las articulaciones:
                       
                           %Cinemática inversa de las secciones metiendo un
                           %pequeño incremento positivo en BETA
                           jointPos = obj.sectionIKine(i, [beta(i)+0.0001 phi(i) 1], 'hrr');
                           
                           sectionConfig = joints2config(i, jointPos);                   
                           newConfig(firstLink:lastLink) = sectionConfig(1:obj.NLinks(i));
                           newPos = tform2trvec(obj.fKine(newConfig));
                           
                           %Cálculo del incremento que se produce en el error:                       
                           de_Beta(i) = norm(newPos - targetPos) - e;
                       
                   %de_Phi:
                       %Cálculo de la nueva configuracion para las articulaciones:
                       
                           %Cinemática inversa de las secciones metiendo un
                           %pequeño incremento positivo en PHI
                           jointPos = obj.sectionIKine(i, [beta(i) phi(i)+0.0001 1], 'hrr');
                           
                           sectionConfig = joints2config(i, jointPos);                   
                           newConfig(firstLink:lastLink) = sectionConfig(1:obj.NLinks(i));
                           newPos = tform2trvec(obj.fKine(newConfig));
                           
                       %Cálculo del incremento que se produce en el error:
                           de_Phi(i) = norm(newPos - targetPos) - e;

               end
               
               beta = beta - de_Beta * k * e;
               phi = phi - de_Phi * k * e;
               
           %CÁLCULO DE NUEVA POSICIÓN
               lastLink = 0;               
               for i = 1:obj.NSections                   
                   firstLink = lastLink + 1;
                   lastLink = firstLink + obj.NLinks(i)-1;
                   
                   %Cálculo de la nueva configuracion para las articulaciones:
                       jointPos = obj.sectionIKine(i, [beta(i) phi(i) 1], 'hrr');
                       sectionConfig = joints2config(i, jointPos);                   
                       newConfig(firstLink:lastLink) = sectionConfig(1:obj.NLinks(i));
               end
               
               newPos = tform2trvec(obj.fKine(newConfig));
               
           %CÁLCULO DEL ERROR E INCREMENTO DE ITERACION
               e = norm(newPos - targetPos);
               %plot(iter, e, 'or'); hold on;  %------------IMPRIMIR ERROR
               
           %COMPROBACIÓN DE LA CONVERGENCIA
               iter = iter + 1;
               if (e > epsilon)&&(iter > m)
                   iter = maxIter;
               end
            end
            %hold off;  %------------------------------------IMPRIMIR ERROR
            logService('DEBUG', 'FIN - ikineGradientDescent');
        end
        
        %% IKINE JACOBI
        function [newConfig, e, iter] = iKineJacobi(obj, tform, varargin)
            logService('DEBUG', 'INI - ikineJacobi');
            
            config = obj.Config;
            
            for i = 1:2:length(varargin)
                switch varargin{i}                       
                    case 'InitConfig'
                       config = varargin{i+1};
                end
            end
            
            initTForm = getTransform(obj, config, obj.EndLink);
            initPos = tform2trvec(initTForm);
            
            targetPos = tform2trvec(tform);
            
            deltaPos = (targetPos - initPos)';
            
            J = obj.jacobian();
            J = J(1:3, :);
            
            q0 = config2joints(obj.Config);
            q = q0;
            
            z = linsolve(J*J', deltaPos);
            deltaq = J' * z;
            
            q = q0 + deltaq;
            q(1) = 0;
            
            newConfig = joints2configTot(q, obj.NLinks);
            
            iter = 1;
            tform = obj.fKine(newConfig);
            newPos = tform2trvec(tform);
            e = norm(newPos-targetPos);
            
            logService('DEBUG', 'FIN - ikineJacobi');
        end
        
        %% IKINE HRR
        function [newConfig, e, iter] = iKineHRR(obj, tform, varargin)
            logService('DEBUG', 'INI - ikineJacobiHRR');
            maxAngle = 0.20;
            initTForm = getTransform(obj, obj.Config, obj.EndLink);
            initPos = tform2trvec(initTForm);
            
            targetPos = tform2trvec(tform);
            
            deltaPos = (targetPos - initPos)';
            
            J = obj.jacobianHRR();
            J = J(1:3, :);
            
            [betas, phis] = obj.angulosSecciones(config2joints(obj.Config));
            q0 = zeros(1, 2*obj.NSections);
            q0(1:obj.NSections) = betas(1:obj.NSections);
            q0(obj.NSections+1:2*obj.NSections) = phis(1:obj.NSections);
            
            z = linsolve(J*J', deltaPos);
            deltaq = J' * z;
            
            %deltaq = J\deltaPos;
            
            q = q0 + deltaq';
            
            for i = 1:obj.NSections
                    sectionJoints = obj.sectionIKine2(i, [q(i) q(i+obj.NSections) 1], 'hrr');
                    %sectionJoints = obj.sectionIKine(i, [q(i) q(i+obj.NSections) 1], 'hrr');
                    for j = 1:length(sectionJoints)
                        if sectionJoints(j) > maxAngle
                            sectionJoints(j) = maxAngle;
                        elseif sectionJoints(j) < -1*maxAngle
                            sectionJoints(j) = -1*maxAngle;
                        end
                    end
                    obj.setSectionConfig(i, joints2config(i, sectionJoints));
            end
            newConfig = obj.Config;
            iter = 1;
            tform = obj.fKine(newConfig);
            newPos = tform2trvec(tform);
            e = norm(newPos-targetPos);
            
            logService('DEBUG', 'FIN - ikineJacobiHRR');
         end
         
        %% JACOBIAN MATRIX
        function [J] = jacobian(obj, varargin)
            %Inicializaciones:
            delta = 1e-6;                %Diferencial de la variable
            config = obj.Config;        %Configuración de partida
            jacobianType ='Analytic';   %Tipo de jacobiana deseada            
            
            for i = 1:2:length(varargin)
                switch varargin{i}
                    case 'Delta'                       
                       delta = varargin{i+1};
                       
                    case 'Config'
                       config = varargin{i+1};
                       
                    case 'JacobianType'
                       jacobianType = varargin{i+1};
                end
            end
            
            %ANALYTIC JACOBIAN
            if strcmp(jacobianType, 'Analytic')
                tform = getTransform(obj, config, obj.EndLink);
                initPosition = tform2trvec(tform);
                initOrientation = tform2eul(tform);
                q0 = config2joints(config);
                
                J = zeros(6, obj.TotalLinks);
                
                for i = 1:obj.TotalLinks
                    q = q0;
                    q(i) = q0(i) + delta;
                    
                    tform = getTransform(obj, joints2configTot(q, obj.NLinks), obj.EndLink);
                    newPosition = tform2trvec(tform);
                    newOrientation = tform2eul(tform);
                    
                    J(1, i) = (newPosition(1) - initPosition(1))/delta;
                    J(2, i) = (newPosition(2) - initPosition(2))/delta; 
                    J(3, i) = (newPosition(3) - initPosition(3))/delta;                    
                    
                    J(4, i) = (newOrientation(1) - initOrientation(1))/delta;
                    J(5, i) = (newOrientation(2) - initOrientation(2))/delta; 
                    J(6, i) = (newOrientation(3) - initOrientation(3))/delta;
                end
            end
        end
        
        function [J] = jacobianHRR(obj, varargin)
            %Inicializaciones:
            delta = 1e-6;                %Diferencial de la variable
            config = obj.Config;        %Configuración de partida
            jacobianType ='Analytic';   %Tipo de jacobiana deseada            
            
            for i = 1:2:length(varargin)
                switch varargin{i}
                    case 'Delta'                       
                       delta = varargin{i+1};
                       
                    case 'Config'
                       config = varargin{i+1};
                       
                    case 'JacobianType'
                       jacobianType = varargin{i+1};
                end
            end
            
            %ANALYTIC JACOBIAN
            if strcmp(jacobianType, 'Analytic')
                tform = getTransform(obj, config, obj.EndLink);
                initPosition = tform2trvec(tform);
                initOrientation = tform2eul(tform);
                
                [betas, phis] = obj.angulosSecciones(config2joints(config));                
                q0 = zeros(1, 2*obj.NSections);
                q0(1:obj.NSections) = betas(1:obj.NSections);
                q0(obj.NSections+1:2*obj.NSections) = phis(1:obj.NSections);
                
                J = zeros(6, 2*obj.NSections);
                %Beta components
                for i = 1:obj.NSections
                    q = q0;
                    q(i) = q0(i) + delta;
                    
                    sectionJoints = obj.sectionIKine(i, [q(i) q(i+obj.NSections) 1], 'hrr');
                    qq = obj.changeSectionConfig(i, sectionJoints);
                    
                    tform = getTransform(obj, qq, obj.EndLink);
                    newPosition = tform2trvec(tform);
                    newOrientation = tform2eul(tform);
                    
                    J(1, i) = (newPosition(1) - initPosition(1))/delta;
                    J(2, i) = (newPosition(2) - initPosition(2))/delta; 
                    J(3, i) = (newPosition(3) - initPosition(3))/delta;                    
                    
                    J(4, i) = (newOrientation(1) - initOrientation(1))/delta;
                    J(5, i) = (newOrientation(2) - initOrientation(2))/delta; 
                    J(6, i) = (newOrientation(3) - initOrientation(3))/delta;
                end
                
                %Phi components
                for i = 1:obj.NSections
                    q = q0;
                    q(i+obj.NSections) = q0(i+obj.NSections) + delta;                    
                    
                    sectionJoints = obj.sectionIKine(i, [q(i) q(i+obj.NSections) 1], 'hrr');
                    qq = obj.changeSectionConfig(i, sectionJoints);
                    
                    tform = getTransform(obj, qq, obj.EndLink);
                    newPosition = tform2trvec(tform);
                    newOrientation = tform2eul(tform);
                    
                    J(1, i+obj.NSections) = (newPosition(1) - initPosition(1))/delta;
                    J(2, i+obj.NSections) = (newPosition(2) - initPosition(2))/delta; 
                    J(3, i+obj.NSections) = (newPosition(3) - initPosition(3))/delta;                    
                    
                    J(4, i+obj.NSections) = (newOrientation(1) - initOrientation(1))/delta;
                    J(5, i+obj.NSections) = (newOrientation(2) - initOrientation(2))/delta; 
                    J(6, i+obj.NSections) = (newOrientation(3) - initOrientation(3))/delta;
                end
            end
        end
        %% CHANGE SECTION CONFIG
        function [newConfig] = changeSectionConfig(obj, index, sectionJoints, varargin)
            firstLink = 1;
            newConfig = obj.Config;
            
            for i = 1:2:length(varargin)
                switch varargin{i}
                    case 'RobotConfig'
                       newConfig = varargin{i+1};
                end
            end
            
            for i = 1:index-1
               firstLink = firstLink + obj.NLinks(i); 
            end
            lastLink = firstLink + obj.NLinks(index) - 1;
            
            for i = firstLink:lastLink
               newConfig(i).JointPosition = sectionJoints(i-firstLink+1);    
            end
        end
        
        %% SET SECTION CONFIG
        function setSectionConfig(obj, index, sectionConfig)
            firstLink = 1;
            for i = 1:index-1
               firstLink = firstLink + obj.NLinks(i); 
            end
            lastLink = firstLink + obj.NLinks(index) - 1;
            
            for i = firstLink:lastLink
                obj.Config(i).JointPosition = sectionConfig(i-firstLink+1).JointPosition;
            end
        end
        
        %% SET CONFIG
        function setConfig(obj, config)
           obj.Config = config;
        end
        
        function resetConfig(obj)
           obj.Config = homeConfiguration(obj);
        end
        
        %% MOVE
        function [newConfig, error, iter] = move(obj, x, y, z, type, varargin)
            N = length(x);
            newConfig = cell(1, N);
            error = cell(1, N);
            iter = cell(1, N);
            logService('DEBUG', N);
            for i=1:N
                tform = trvec2tform([x(i), y(i), z(i)]);
                switch type
                    case 'GradientDescent'
                        [newConfig{i}, error{i}, iter{i}] = obj.iKineGradientDescent(tform, varargin{:});

                    case 'Jacobian'
                        [newConfig{i}, error{i}, iter{i}] = obj.iKineJacobi(tform, varargin{:});

                    case 'JacobianHRR'
                        [newConfig{i}, error{i}, iter{i}] = obj.iKineHRR(tform, varargin{:});

                    case 'Default'
                        [newConfig{i}, error{i}, iter{i}] = obj.iKine(tform, varargin{:});

                    otherwise
                        [newConfig{i}, error{i}, iter{i}] = obj.iKine(tform, varargin{:});
                end
                
            end
            
            figure;
            
            for i=1:N
                obj.setConfig(newConfig{i});
                obj.plot2();
                axis([-250 250 -250 250 0 250])
                hold on;
                plot3(x,y,z,'LineWidth',2);
                drawnow
                hold off;
%                 M(i) = getframe(gcf)
            end
            
%             figure;
%             axes('Position',[0 0 1 1]);
%             movie(M,50,5)
end
        
        %% MOVE TRAJECTORY
        function [newConfig, error, iter] = moveTrayectory(obj, x, y, z, type, N, traj, varargin)
            newConfig = cell(1, N);
            error = cell(1, N);
            iter = cell(1, N);
            
            currentPos = tform2trvec(obj.fKine(obj.Config));
            [X, Y, Z] = trajectory3(currentPos, [x y z], N, traj);
            for i = 1:N
                [newConfig{i}, error{i}, iter{i}] = obj.move(X(i), Y(i), Z(i), type, varargin{:});
            end
        end
            
        %% MAX MANIP CONFIG
        function [newConfig, manip_ant, iter] = maxManipConfig(obj, varargin)
            %INICIALIZACIONES:
            currentConfig = obj.Config;
            
            iter = 0;      %Contador de iteraciones.
            maxIter = 200; %Máximo de iteraciones.
            maxIterIKine = 20;
            
            eMax = 0.1;   %Error deseado en el posicionamiento
            k = 1;      %Constante de correcion
            
            dm_x = 0; dm_y = 0; dm_z = 0;
            
            for i = 1:2:length(varargin)
                switch varargin{i}
                    case 'Error'
                       ef = varargin{i+1};
                       
                    case 'MaxIter'
                       maxIter = varargin{i+1};
                       
                    case 'k'
                       k = varargin{i+1};
                       
                    case 'InitConfig'
                       currentConfig = varargin{i+1};
                       
                    case 'm'
                       m = varargin{i+1};
                       
                    case 'epsilon'
                       epsilon = varargin{i+1};
                end
            end
            
            newConfig = currentConfig;
            
            J = obj.jacobianHRR('Config', newConfig);
            JJt = J * J';
            manip_ant = manipulability(JJt);
            manip = manip_ant + 1;
            
            while  (manip > manip_ant) && (iter < maxIter)
                   manip = manip_ant;
                   
                   tform = obj.fKine(newConfig);
                   currentPos = tform2trvec(tform);
                   
                   %dm_x:                       
                           %Cinemática inversa metiendo un pequeño incremento en X
                           newPos = [currentPos(1)+0.0001 currentPos(2) currentPos(3)];
                           
                           error = eMax +1;
                           ii = 0;
                           
                           while (error > eMax)&&(ii < maxIterIKine)
                               [newConfig, error, ~] = obj.iKineHRR(trvec2tform(newPos));
                               ii = ii + 1;
                           end
                       %Cálculo del incremento que se produce en la manipulabilidad:            
                           J = obj.jacobianHRR('Config', newConfig);
                           JJt = J * J';
                           manip_aux = manipulability(JJt);
            
                           dm_x = manip_aux - manip_ant;
                   
                   %dm_y:                       
                           %Cinemática inversa metiendo un pequeño incremento en Y
                           newPos = [currentPos(1) currentPos(2)+0.0001 currentPos(3)];
                           
                           error = eMax +1;
                           ii = 0;
                           
                           while (error > eMax)&&(ii < maxIterIKine)
                               [newConfig, error, ~] = obj.iKineHRR(trvec2tform(newPos));
                               ii = ii + 1;
                           end
                       %Cálculo del incremento que se produce en la manipulabilidad:            
                           J = obj.jacobianHRR('Config', newConfig);
                           JJt = J * J';
                           manip_aux = manipulability(JJt);
            
                           dm_y = manip_aux - manip_ant;
                   
                   %dm_z:                       
                           %Cinemática inversa metiendo un pequeño incremento en Z
                           newPos = [currentPos(1) currentPos(2) currentPos(3)+0.0001];
                           
                           error = eMax +1;
                           ii = 0;
                           
                           while (error > eMax)&&(ii < maxIterIKine)
                               [newConfig, error, ~] = obj.iKineHRR(trvec2tform(newPos));
                               ii = ii + 1;
                           end
                       %Cálculo del incremento que se produce en la manipulabilidad:            
                           J = obj.jacobianHRR('Config', newConfig);
                           JJt = J * J';
                           manip_aux = manipulability(JJt);
            
                           dm_z = manip_aux - manip_ant;
               
               currentPos(1) = currentPos(1) + dm_x * k;
               currentPos(2) = currentPos(2) + dm_y * k;
               currentPos(3) = currentPos(3) + dm_z * k;
               
           %CÁLCULO DE NUEVA POSICIÓN
               tform = trvec2tform(currentPos);
               
               error = eMax +1;
               ii = 0;

               while (error > eMax)&&(ii < maxIterIKine)
                   [newConfig, error, ~] = obj.iKineHRR(tform);
                   ii = ii + 1;
               end
               
           %CÁLCULO DE LA MANIPULABILIDAD OBTENIDA            
               J = obj.jacobianHRR('Config', newConfig);
               JJt = J * J';
               manip_ant = manipulability(JJt);
               
               iter = iter + 1;
            end
        end
        
        %% ÁNGULOS SECCIONES
        function [betas, phis] = angulosSecciones (obj,positions)

            n=0;
            phis=zeros(obj.NSections,1);
            betas=zeros(obj.NSections,1);
            for i=1:obj.NSections
                pos = zeros(1, obj.NLinks(i));
                pos(1:obj.NLinks(i))=positions(1+n:n+obj.NLinks(i));
                n=n+obj.NLinks(i);
                b=obj.A{i}*pos';
                %phis(i)=atan2(b(2), b(1));
                %betas(i)=norm(b);
                [betas(i), phis(i)] = corrigeBetaPhi(norm(b), atan2(b(2), b(1)));
            end
        end

    end
    
    methods (Access = private)
        %% CREATE BASE
        function createBase(obj)
            base = HRRBase('base');
            addBody(obj, base, 'base');
        end
        
        %% CREATE SECTIONS
        function createSections(obj)
            for i = 1:obj.NSections
                %Creates the new section:
                newSection = HRRSection(i, obj.NLinks(i), obj.Alpha(i));
                obj.Assembly{i} = newSection.Assembly;
                
                %Inicializations:
                obj.A{i} = newSection.A;
                
                %Adding section in position:
                if i == 1
                    pos = [0 0 3];
                    eul = [0 0 0];
                    tform = eul2tform(eul) * trvec2tform(pos);
                    setFixedTransform(newSection.Bodies{1}.Joint, tform);
                    addSubtree(obj, 'base', newSection);
                else
                    pos = [0 0 5];
                    eul = [obj.Assembly{i}(1) 0 0];
                    tform = eul2tform(eul) * trvec2tform(pos);
                    setFixedTransform(newSection.Bodies{1}.Joint, tform);
                    addSubtree(obj, endLink, newSection);
                end
                
                endLink = newSection.EndLink;
            end
        end
    end
end
