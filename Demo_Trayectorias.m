NPoints = 10;

q = cell(1, 10); %Vector de configuraciones.

P1 = [60 60 120];
P2 = [100 -150 150];
P3 = [0 0 200];
P4 = [0 0 258];

robot = HRRobot([20 12 12 8], [pi/2 pi/2 pi/2 pi/2]);
robot.move(P1(1), P1(2), P1(3), 'GradientDescent');

disp("Calculando trayectorias...");

disp(1);


dx = (P2(1) - P1(1))/NPoints;
dy = (P2(2) - P1(2))/NPoints;
dz = (P2(3) - P1(3))/NPoints;

for i = 1:NPoints
    [q{1, i}, ~, ~] = robot.move(P1(1)+dx*i, P1(2)+dy*i, P1(3)+dz*i, 'JacobianHRR');
end

disp("Imprimiendo...");
h = figure;
h.Visible = 'off';
M(NPoints) = struct('cdata',[],'colormap',[]);
for i = 1:NPoints
    robot.plot2('Config', q{1, i}, 'Visuals', 'off');
    drawnow;
    M(i) = getframe;
end
h.Visible = 'on';
movie(M);

function q = calculateTrajectory(R, O, P, NPoints)
    dx = (P(1) - O(1))/NPoints;
    dy = (P(2) - O(2))/NPoints;
    dz = (P(3) - O(3))/NPoints;
    
    q = cell(1, NPoints);
    
    for i = 1:NPoints
        [q{i}, ~, ~] = R.move(O(1)+dx*i, O(2)+dy*i, O(3)+dz*i, 'JacobianHRR');
    end
end