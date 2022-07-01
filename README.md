# Pylori-I

Este proyecto contiene el código necesario para simular el comportamiento y controlar el movimiento del robot Pylori-I del CAR de la UPM.

Para poder ejecutar este código hay que tener en cuenta varias cosas:
	1. El archivo .ino debe estar cargado en el Arduino Due que contiene el armario. Y de usarse en otro arduino habría además que cargar la librería AccelStepper
	2. El armario debe encenderse correctamente antes de intentar mover el robot: hay que comprobar que el magnetotérmico del interior este subido, la seta de emergencia no esté pulsada y entonces encender el armario.
	3. El código con la cinemática está escrito en MATLAB R2020 o R2021, y el que mueve el robot en MATLAB R2022a, por lo que si se usa en versiones posteriores puede que esté desfasado.

COMO SE USA ESTE CÓDIGO:
	> Las funciones Demo y Demo_Trayectorias sirven para simular la cinemática del robot cuando se mueve a un punto (definido en caartesianas), en el caso de Demo, o traza una trayectoria pasando por varios puntos (también en cartesianas), en el caso de Demo_trayectorias; y devuelven los datos necesarios para mover el robot hasta ese punto o trazar esa trayectoria mediante la función moverRobot.
	
	> IMPORTANTE: antes de empezar a ejecutar cualquier función que se comunique con Arduino (moverRobot, calibrarRobot, mover_motor) hay que abrir la conexión con Arduino como se muestra a continuación:
		>> ardu=serialport("COM3",250000);
	donde "COM3" se deve sustituir por el puerto que esté ocupando Arduino. Y lo primero que hay que hacer después de establecer la conexión es establecer la posición actual como la inicial:
		>>  calibrarRobot(ardu,0,1);
	Esta conexión no se debe cerrar hasta que no se haya terminado de mover el robot o se perderá los datos sobre cual es la posición inicial. Antes de cerrar se devuelve el robot a la posición inicial y despues se cierra la conexión borrando el objeto ardu:
		>> calibrarRobot(ardu,2,1);
		>> delete(ardu);

 Una vez abierta la conexión y establecida la posición inicial, las formas de mover el robot son las siguientes:
 	> para mover motor a motor (mediante la función mover_motor). Si se quiere mover motor m hasta la posición pos(en pulsos) a la velocidad vel (en pulsos/s):
 		>> mover_motor(ardu,m,2,vel,pos,1);
 	Si se quiere mover motor m a la velocidad vel (en pulsos/s) durante s segundos:
		>> mover_motor(ardu,m,1,vel,0,s);

 	> para moverlo a un punto (x,y,z):
		>> [newConfig,error,iter,currentPos]=Demo(x,y,z);
		>> moverRobot(ardu,newConfig,0,1);
	Donde el 0 en el tercer argumento de moverRobot indica que es un punto y no una trayectoria y el cuarto argumento indica que es un solo punto. Además, la variable error da el error que se espera de la simulación, la variable iter, el nº de iteraciones que ha tenido que hacer la simulación.
 	> para moverlo siguiendo una trayectoria:

 	> para llevar el robot a la posición inicial:
		>> calibrarRobot(ardu,2,1);
	> para establecer la posición actual como la inicial:
		>> calibrarRobot(ardu,0,1); 	
