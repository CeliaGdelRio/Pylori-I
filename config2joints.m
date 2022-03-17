function positions = config2joints(config)
%JOINTS2CONFIG
nLinks = length(config);
positions = zeros(nLinks,1);
for i = 1:nLinks
    positions(i) = config(i).JointPosition;
end
end

