function config = joints2config(index,positions)
%JOINTS2CONFIG
config = struct('JointName', {}, 'JointPosition', []);
nLinks = length(positions);
for i = 1:nLinks
    config(i).JointName = "L" + index + "." + i + "_Joint";
    config(i).JointPosition = positions(i);
end
end

