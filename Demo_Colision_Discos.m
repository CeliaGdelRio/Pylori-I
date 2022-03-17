%1º Leer el .stl
    stl = stlread('Mod_Boro_Triang.stl');

%2º Generar la malla a partir del .stl
    link1 = collisionMesh(stl.Points);
    link2 = collisionMesh(stl.Points);
    
%3º Situar las mallas en la posición del disco
    link1.Pose = getTransform(robot, newConfig, 'L4.7');
    link2.Pose = getTransform(robot, newConfig, 'L4.6');

%4º Graficar los discos, guardando el objeto "Patch"
    figure;
    [~, p1] = show(link1); hold on; [~, p2] = show(link2);

%5º Editar las propiedas de los "Patch" para establecer el color
    p1.EdgeColor = 'none';
    p1.FaceColor = [0 1 0];

    p2.EdgeColor = 'none';
    p2.FaceColor = [0 0 1];

%6º Comprobar la colision
    colision = checkCollision(link1, link2);
