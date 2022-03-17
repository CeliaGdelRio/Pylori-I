classdef HRRLink < HRRObject
    %HRRLINK Cada disco del robot.
    %
    %HRRLink(name)
    %HRRLink(name, H, R)
    %
    %H = altura desde la base hasta el punto de pivote.
    %R = radius hasta la línea media de los orificios para cables.
    
    properties
        H;
        R;
    end
    
    methods
        function obj = HRRLink(name, varargin)           
            obj@HRRObject(name);
            
            %Default inicializations:            
            obj.H = 5.0;
            obj.R = 7.25;
            
            position = [0 0 0];
            euler = [0 0 0];
            
            visuals = 'off';
            
            %Customized inicializations:
            for i = 1:2:length(varargin)
                switch varargin{i}
                    case 'H'
                       obj.H = varargin{i+1};
                       
                    case 'R'
                       obj.R = varargin{i+1};
                       
                    case 'Visuals'
                       visuals = varargin{i+1};
                       
                    case 'Position'
                       position = varargin{i+1};
                       
                   case 'Euler'
                       euler = varargin{i+1};
                end
            end
            
            %Joint creation:
            joint = rigidBodyJoint(obj.Name + "_Joint",'revolute'); %Creation
            
            joint.HomePosition = 0;                                 %Settings
            joint.JointAxis = [1 0 0];
            tform = eul2tform(euler) * trvec2tform(position);            
            setFixedTransform(obj.Joint, tform);                    %Position
            
            obj.Joint = joint;                                      %Inicialization  
            
            %Visuals:
            if strcmp(visuals, 'on')
                obj.addVisual("Mesh", "Mod_Boro_Triang.stl");
            end
        end
    end
end

