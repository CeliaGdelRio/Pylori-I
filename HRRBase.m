classdef HRRBase < HRRObject
    %HRRBASE Disco fijo al que va unido el robot.
    % 
    %H = distancia desde la base hasta el punto de unión con la base del
    %   primer disco del robot.
    
    properties
        H;
    end
    
    methods
        function obj = HRRBase(name,varargin)
            obj@HRRObject(name);
            
            %Default inicilizations:
            obj.H = 3;
            visuals = 'off';
            position = [0 0 0];
            
            %Customized inicializations:
            for i = 1:2:length(varargin)
                switch varargin{i}
                    case 'H'
                       obj.H = varargin{i+1};
                       
                    case 'Visuals'
                       visuals = varargin{i+1};
                       
                    case 'Position'
                       position = varargin{i+1}; 
                end
            end           
            
            %Fixed Joint creation:
            joint = rigidBodyJoint(obj.Name + "_Joint", 'fixed');   %Creation
            setFixedTransform(joint, trvec2tform(position));        %Position
            obj.Joint = joint;                                      %Inicialization
            
            %Visuals:
            if strcmp(visuals, 'on')
                obj.addVisual("Mesh", "Robot_Base.stl");
            end
        end
    end
end

