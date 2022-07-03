
%Definimos número de puntos de la trayectoria (ahora mismo son el doble de
%N), el radio del círculo y el punto inicial.
N = 6;
z=258;
r=104;
q = cell(1, N); %Vector de configuraciones.

P1 = [-r 0 z];

%Creamos el objeto robot
Assembly = {[0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0];
            [(pi/2.0-2*pi/16) -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0];
            [(pi/2.0-2*pi/16) -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0];
            [(pi/2.0-2*pi/16) -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0 pi/2.0 -pi/2.0]};
robot = HRRobot([20 12 12 8], Assembly);

%Se calculan los puntos del círculo
x1 = linspace(-104,104,N/2+1);
x2 = linspace(104,-104,N/2+1);
y1 = abs(sqrt(104^2-x1.^2));
y2=-abs(sqrt(104^2-x2.^2));

figure
plot(x1,y1,x2,y2)

disp("Calculando trayectorias...");
disp(1);

% for i = 1:N
%     [q{1, i}, ~, ~] = robot.move(x1(i), y1(i),z, 'GradientDescent');
% end
for i = 1:(N+1)
    if i<=N/2
        [q{1,i}, ~, ~] = robot.move(x1(i), y1(i),z, 'GradientDescent');
    else
        [q{1,i}, ~, ~] = robot.move(x2(i-(N/2)), y2(i-(N/2)),z, 'GradientDescent');
    end
end

disp("Imprimiendo...");
h = figure;
h.Visible = 'off';
M(N) = struct('cdata',[],'colormap',[]);
for i = 1:N
    robot.plot2('Config', q{1, i}, 'Visuals', 'off');
    drawnow;
    M(i) = getframe;
end
h.Visible = 'on';
movie(M);
