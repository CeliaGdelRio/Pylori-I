classdef HRRObject < rigidBody
    %HRROBJECT Basic HRR Part
    %   Detailed explanation goes here
    
    methods
        function obj = HRRObject(name, varargin)
            obj@rigidBody(name, varargin{:});
        end
    end
end

