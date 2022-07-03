points = successPointsCondensed;
manip = manipulabilities;
maxManip = 2e5;
minManip = 1e3;
N = length(manip);

for i = 1:N
    k = (manip(i) - minManip)/(maxManip-minManip);
    if k > 1
        k = 1;
    elseif k < 0
        k = 0;
    end
    color = [0 0 1] * k;
    plot(points{i}(1), points{i}(3), 'o', 'MarkerEdgeColor', color, 'MarkerFaceColor',color);
    hold on;
end
axis equal;
xlim([0 750]);
ylim([-500 500]);
