classdef HRRSection < rigidBodyTree
    %HRRSECTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Index;
        NLinks;
        EndLink;
        Assembly;
        %Alpha;
        A;
    end
    
    methods (Access = public)
        function obj = HRRSection(Index, NLinks, Assembly, varargin)
            obj@rigidBodyTree;
            obj.Index = Index;
            obj.NLinks = NLinks;
            %obj.Alpha = Alpha;
            obj.Assembly = Assembly;
            obj.createLinks;
            obj.EndLink = obj.BodyNames{obj.NLinks};
            obj.A = obj.calculateA();
        end
    end
    
    methods (Access = private)
        function A = calculateA(obj)
            %CALCULATEA Calculates the "A" matrix for the iKineHRR method.
            
            %Inicializations:
            alpha = 0;
            A = ones(2, obj.NLinks);
            
            %Calculate A:
            for i = 1:obj.NLinks
                alpha = alpha + obj.Assembly(i);
                A(1, i) = cos(alpha);
                A(2, i) = sin(alpha);
            end
        end
        
        function linkName = nameLink(obj, linkIndex)
            linkName = "L" + obj.Index + "." + linkIndex;
        end
        
        function addLink(obj, linkIndex, destination, zDistance)
            %ADDLINK Adds a new link to the section, in the linkIndex
            %position.
            
            %Creation of the new link:
            newLink = HRRLink(obj.nameLink(linkIndex));
            
            %Setting position:
            if linkIndex == 1
                %If it's the first link...
                pos = [0 0 0];
            else
                pos = [0 0 zDistance];
            end
            
            %Setting orientation:
            eul = [obj.Assembly(linkIndex) 0 0];
            
            %Setting tform matrix:
            tform = eul2tform(eul) * trvec2tform(pos);
            
            setFixedTransform(newLink.Joint, tform);
            addBody(obj, newLink, destination);
        end
        
        function createLinks(obj)
            %CREATELINKS Creates and attaches the links.
            if obj.NLinks == 0
               disp("Not enought links in Section" + obj.Index + " (NLinks = 0).");
      
            else                
                for i = 1:obj.NLinks
                    if i == 1
                        obj.addLink(i, 'base', 0);
                    else
                        obj.addLink(i, obj.nameLink(i-1), 5);
                    end
                end
            end
        end
    end
end

