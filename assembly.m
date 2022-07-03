function g = assembly(NLinks, alpha, n)
%NLinks: vector with the number of links in each section
%alpha: vector of angles between links in each section
%n: vector of number of links in a subsection of each section
    
    NSections = length(NLinks);
    
    g = cell(1, NSections);
    g1 = 0;
    
    for s = 1:NSections
        g{s} = zeros(1, NLinks(s));        
    end
    
    for s = 1:NSections
        [g{s}, g1] = sectionAssembly(NLinks(s), alpha(s), n(s), g1);
        g1 = -g1;
    end
end

function [g, gf] = sectionAssembly(NLinks, alpha, n, g1)
%NLinks: total number of links in the section
%alpha: angle between links
%n: number of links in a subsection
%g1: alpha angle of the first link of the section

    g = zeros(1, NLinks);
    g(1) = g1;
    count = 1;
    
    alphaRestart = (1 - n) * alpha;
    
    for i = 2:NLinks
        if count ~= n
            g(i) = alpha;
            count = count + 1;
        else
            g(i) = alphaRestart;
            count = 1;
        end
    end
    
    gf = (count-1) * alpha;
end

