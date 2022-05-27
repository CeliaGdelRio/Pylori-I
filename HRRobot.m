%30/04/2021

classdef HRRobot < HRRTree
    %HRROBOT Objeto Robot Hiperredundante.
    
    properties
        BaseSTL_File;
        LinkSTL_File;
        BaseSTL;
        LinkSTL;
    end
    
    methods (Access = public)
        %% CONSTRUCTOR
        function obj = HRRobot(NLinks, Asembly)
            obj@HRRTree(NLinks, Asembly);
            %Default STL files:
            obj.BaseSTL_File = "Robot_Base.stl";
            obj.LinkSTL_File = "Mod_Boro_Triang.stl";
            obj.BaseSTL = 0;
            obj.LinkSTL = 0;
        end
        
        %% PLOT
        function plot(obj, varargin)
            obj.show(obj.Config, varargin{:});
            obj.tipAxes();
        end
        
        %% PLOT2
        function plot2(obj, varargin)
            baseColor = [1 1 1];
            bodyColor = [0 0 1];
            endLinkColor = [0 1 0];
            
            config = obj.Config;
            visuals = 'on';
            
            %Customized settings:
            for i = 1:2:length(varargin)
                switch varargin{i}
                    case 'Config'
                       config = varargin{i+1};
                       
                    case 'BaseColor'
                       baseColor = varargin{i+1};
                       
                    case 'BodyColor'
                       bodyColor = varargin{i+1};
                       
                    case 'EndLinkColor'
                       endLinkColor = varargin{i+1};
                       
                    case 'Visuals'
                       visuals = varargin{i+1};
                end
            end
            
            if strcmp(visuals, 'on')
                %Si no se han leÃ­do los STL, los lee:
                if ~((isempty(obj.BaseSTL))||(isempty(obj.LinkSTL)))
                    obj.addVisuals();
                end
                
                %Generar la malla a partir del STL
                base = collisionMesh(obj.BaseSTL.Points);
                link = collisionMesh(obj.LinkSTL.Points);

                base.Pose = getTransform(obj, config, obj.BaseName);
                [~, patchObj] = show(base);
                hold on;
                patchObj.EdgeColor = 'none';
                patchObj.FaceColor = baseColor;

                lastLink = 0;
                for j = 1:obj.NSections
                    for i = 1:obj.NLinks(j)
                        %Situar las mallas en la posiciÃ³n del disco
                        link.Pose = getTransform(obj, config, obj.BodyNames{1, lastLink+i});

                        %Graficar los discos, guardando el objeto "Patch"
                        [~, patchObj] = show(link);
                        hold on;
                        
                        %Editar las propiedas de los "Patch" para establecer el color
                        patchObj.EdgeColor = 'none';
                        if j==1
                            if i < obj.NLinks(j)
                                patchObj.FaceColor = [1 0 0];           %------bodyColor;
                            else
                                patchObj.FaceColor =[1 1 1];            %------endLinkColor;
                            end
                        elseif j==2
                            if i < obj.NLinks(j)
                                patchObj.FaceColor = [0 1 0];           %------bodyColor;
                            else
                                patchObj.FaceColor = [1 1 1];           %------endLinkColor;
                            end
                        elseif j==3
                            if i < obj.NLinks(j)
                                patchObj.FaceColor = [0 0 1];            %-----bodyColor;
                            else
                                patchObj.FaceColor = [1 1 1];            %-----endLinkColor;
                            end
                        elseif j==4
                            if i < obj.NLinks(j)
                                patchObj.FaceColor = [0 0 0];            %-----bodyColor;
                            else
                                patchObj.FaceColor = [1 1 1];            %-----endLinkColor;
                            end
                        end
                        
                        
%                         if i < obj.NLinks(j)
%                             patchObj.FaceColor = bodyColor;
%                         else
%                             patchObj.FaceColor = endLinkColor;
%                         end
                    end
                    lastLink = lastLink + obj.NLinks(j);
                end
            
            else
                obj.plot('Visuals', 'off');
            end
            
            obj.tipAxes();
            
            hold off;
        end
        
        function tipAxes(obj)
            hold on;
            tform = getTransform(obj, obj.Config, obj.EndLink);
            endPos = tform2trvec(tform);
            endQuat = tform2quat(tform);
            plotTransforms(endPos, endQuat, 'FrameSize', 30);
            
            xlim([-obj.TotalLinks*5 obj.TotalLinks*5]);
            ylim([-obj.TotalLinks*5 obj.TotalLinks*5]);
            zlim([-5 (obj.TotalLinks+1)*5]);
            hold off;
        end
        
        %% ELLIPSOID
        function plotEllipsoid(obj, scale, J)
            eigenValues = eig(J*J');
            s1 = eigenValues(1)*scale;
            s2 = eigenValues(2)*scale;
            s3 = min(eigenValues)*scale;
            
            tform = getTransform(obj, obj.Config, obj.EndLink);
            pos = tform2trvec(tform);
            rot = tform2eul(tform, 'XYZ');
            
            [X, Y, Z] = ellipsoid(pos(1), pos(2), pos(3), s1, s2 , s3);
            surface = surf(X, Y, Z, 'FaceAlpha', 0.25);
            rotate(surface, [rot(1) rot(2) rot(3)], norm(rot)*180/pi, [pos(1) pos(2) pos(3)]);
        end
        
        function [newConfig, manip_ant, iter] = maxManipConfig(obj, varargin)
            %INICIALIZACIONES:
            currentConfig = obj.Config;
            
            iter = 0;      %Contador de iteraciones.
            maxIter = 200; %MÃ¡ximo de iteraciones.
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
                           %CinemÃ¡tica inversa metiendo un pequeÃ±o incremento en X
                           newPos = [currentPos(1)+0.0001 currentPos(2) currentPos(3)];
                           
                           error = eMax +1;
                           ii = 0;
                           
                           while (error > eMax)&&(ii < maxIterIKine)
                               [newConfig, error, ~] = obj.iKineHRR(trvec2tform(newPos));
                               ii = ii + 1;
                           end
                       %CÃ¡lculo del incremento que se produce en la manipulabilidad:            
                           J = obj.jacobianHRR('Config', newConfig);
                           JJt = J * J';
                           manip_aux = manipulability(JJt);
            
                           dm_x = manip_aux - manip_ant;
                   
                   %dm_y:                       
                           %CinemÃ¡tica inversa metiendo un pequeÃ±o incremento en Y
                           newPos = [currentPos(1) currentPos(2)+0.0001 currentPos(3)];
                           
                           error = eMax +1;
                           ii = 0;
                           
                           while (error > eMax)&&(ii < maxIterIKine)
                               [newConfig, error, ~] = obj.iKineHRR(trvec2tform(newPos));
                               ii = ii + 1;
                           end
                       %CÃ¡lculo del incremento que se produce en la manipulabilidad:            
                           J = obj.jacobianHRR('Config', newConfig);
                           JJt = J * J';
                           manip_aux = manipulability(JJt);
            
                           dm_y = manip_aux - manip_ant;
                   
                   %dm_z:                       
                           %CinemÃ¡tica inversa metiendo un pequeÃ±o incremento en Z
                           newPos = [currentPos(1) currentPos(2) currentPos(3)+0.0001];
                           
                           error = eMax +1;
                           ii = 0;
                           
                           while (error > eMax)&&(ii < maxIterIKine)
                               [newConfig, error, ~] = obj.iKineHRR(trvec2tform(newPos));
                               ii = ii + 1;
                           end
                       %CÃ¡lculo del incremento que se produce en la manipulabilidad:            
                           J = obj.jacobianHRR('Config', newConfig);
                           JJt = J * J';
                           manip_aux = manipulability(JJt);
            
                           dm_z = manip_aux - manip_ant;
               
               currentPos(1) = currentPos(1) + dm_x * k;
               currentPos(2) = currentPos(2) + dm_y * k;
               currentPos(3) = currentPos(3) + dm_z * k;
               
           %CÃLCULO DE NUEVA POSICIÃ“N
               tform = trvec2tform(currentPos);
               
               error = eMax +1;
               ii = 0;

               while (error > eMax)&&(ii < maxIterIKine)
                   [newConfig, error, ~] = obj.iKineHRR(tform);
                   ii = ii + 1;
               end
               
           %CÃLCULO DE LA MANIPULABILIDAD OBTENIDA            
               J = obj.jacobianHRR('Config', newConfig);
               JJt = J * J';
               manip_ant = manipulability(JJt);
               
               iter = iter + 1;
            end
        end
        
        %% ÃNGULOS SECCIONES
        function [betas, phis] = angulosSecciones (obj,positions)

            n=0;
            phis=zeros(obj.NSections,1);
            betas=zeros(obj.NSections,1);
            for i=1:obj.NSections
                pos = zeros(1, obj.NLinks(i));
                pos(1:obj.NLinks(i))=positions(1+n:n+obj.NLinks(i));
                n=n+obj.NLinks(i);
                b=obj.A{i}*pos';
                phis(i)=atan2(b(2), b(1));
                betas(i)=norm(b);
                %[betas(i), phis(i)] = corrigeBetaPhi(norm(b), atan2(b(2), b(1)));
            end
        end
        
        %% ADD VISUALS
        function addVisuals(obj, varargin)
            %Default settings:
            baseSTL = obj.BaseSTL_File;
            linkSTL = obj.LinkSTL_File;
            
            %Read STL Files:
            obj.BaseSTL = stlread(obj.BaseSTL_File);
            obj.LinkSTL = stlread(obj.LinkSTL_File);
            
            %Customized settings:
            for i = 1:2:length(varargin)
                switch varargin{i}                       
                    case 'Base'
                       baseSTL = varargin{i+1};
                       
                    case 'Link'
                       linkSTL = varargin{i+1};
                end
            end
            
            obj.Base.addVisual("Mesh", baseSTL);
            
            for i = 1:obj.TotalLinks
                obj.Bodies{i}.addVisual("Mesh", linkSTL);
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
