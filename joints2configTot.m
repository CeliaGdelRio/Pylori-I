function config = joints2configTot(positions, nLinks)
%JOINTS2CONFIGTOT
nSections = length(nLinks);

config = struct('JointName', {}, 'JointPosition', []);
initLink = 0;

for j = 1:nSections
    for i = 1:nLinks(j)
        config(initLink + i).JointName = "L" + j + "." + i + "_Joint";
        config(initLink + i).JointPosition = positions(initLink + i);
    end
    initLink = initLink + nLinks(j);
end
end

