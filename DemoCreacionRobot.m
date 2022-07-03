nLinks = [20, 12, 12, 8];
alfas = [pi/2, pi/2, pi/2, pi/2];
robot1 = HRRobot(nLinks, alfas);
robot1.plot2('BodyColor', 'blue', 'EndLinkColor', 'green');

[newConfig, error, iter] = robot1.move(-104, 0, 215, 'Default');
robot1.plot2();
disp(error);
disp(iter);
disp(robot1.currentPos());
