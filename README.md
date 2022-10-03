# Pylori-I

Este proyecto contiene el código necesario para simular el comportamiento y controlar el movimiento del robot Pylori-I del CAR de la UPM.

Para poder ejecutar este código hay que tener en cuenta varias cosas:
	1. El archivo .ino debe estar cargado en el Arduino Due que contiene el armario. Y de usarse en otro arduino habría además que cargar la librería AccelStepper
	2. El armario debe encenderse correctamente antes de intentar mover el robot: hay que comprobar que el magnetotérmico del interior este subido, la seta de emergencia no esté pulsada y entonces encender el armario.
	3. El código con la cinemática está escrito en MATLAB R2020 o R2021, y el que mueve el robot en MATLAB R2022a, por lo que si se usa en versiones posteriores puede que esté desfasado.
	
### CONTENIDO Y CARPETAS:	

* **Arduino:** Contiene el archivo que debe estar cargado en la placa Arduino Due del armario electrico para poder ejecutar correctamente el código que mueve el robot
* **Images:** Contiene las imagenes que se han empleado para la memoria y algunas mas. Las imagenes que he obtenido de otras fuentes estan debidamente citadas en la memoria TFM_Celia Garijo del Rio.pdf de la carpeta Memorias_TFM. Las demás son de elaboracion propia por lo que se pueden usar citando la memoria (las que aparecen en ella) o este repositorio.
*  **Memorias_TTFM:** Contiene las tres memorias de los trabajos de final de grado o master en los que se ha desarrollado este proyecto.
*  **Red_neuronal:** Contiene el codigo empleado para entrenar las dos redes neuronales en python así como un archivo .csv con los datos que se han empleado en este caso y archivos .txt con las variables (W1, W2, b1, b2, ymin, ymax, xmin y xmax) obtenidas tras entrenar la red que permiten aplicarla en otros programas como Matlab.
*  **Toma de datos:** Contiene el codigo que se ha empleado tanto para la toma de datos del comportamiento del robot como para el tratamiento de datos.
*  **piezas_STL:** Contiene todos los archivos .stl de las piezas mecanicas que se han diseñado para el robot. Para poder ejecutar el codigo que mueve el robot es necesario tener en la misma carpeta los archivos Robot_Base.stl, End_Boro_Triang.stl y Mod_Boro_Triang.stl.

El codigo que queda fuera de las carpetas es el que se emplea para mover el robot y el que contiene la cinematica. A continuacion se describe en mas detalle como usar este ultimo.

### CÓMO SE USA ESTE CÓDIGO:

**IMPORTANTE:** Se ha incluido un archivo .cff en este repositorio para que resulte más sencillo citar este repositorio a quien lo pueda necesitar.

Las funciones Demo y Demo_Trayectorias sirven para simular la cinemática del robot cuando se mueve a un punto (definido en caartesianas), en el caso de Demo, o traza una trayectoria pasando por varios puntos (también en cartesianas), en el caso de Demo_trayectorias; y devuelven los datos necesarios para mover el robot hasta ese punto o trazar esa trayectoria mediante la función moverRobot.
	
**IMPORTANTE:** antes de empezar a ejecutar cualquier función que se comunique con Arduino (moverRobot, calibrarRobot, mover_motor) hay que abrir la conexión con Arduino como se muestra a continuación:
		
```matlab
ardu=serialport("COM3",250000);
```
		
donde "COM3" se deve sustituir por el puerto que esté ocupando Arduino. Y lo primero que hay que hacer después de establecer la conexión es establecer la posición actual como la inicial:
		
```matlab
calibrarRobot(ardu,0,1);
```	
		
Esta conexión no se debe cerrar hasta que no se haya terminado de mover el robot o se perderá los datos sobre cual es la posición inicial. Antes de cerrar se devuelve el robot a la posición inicial y despues se cierra la conexión borrando el objeto ardu:
```matlab
calibrarRobot(ardu,2,1);
delete(ardu);
```

Una vez abierta la conexión y establecida la posición inicial, las formas de mover el robot son las siguientes:
 	
* Para mover motor a motor (mediante la función mover_motor). 
	* Si se quiere mover motor m hasta la posición pos(en pulsos) a la velocidad vel (en pulsos/s):
	```matlab
	mover_motor(ardu,m,2,vel,pos,1);
	```
	* Si se quiere mover motor m a la velocidad vel (en pulsos/s) durante s segundos:
	```matlab
	mover_motor(ardu,m,1,vel,0,s);
	```
* Para moverlo a un punto (x,y,z):
```matlab
[newConfig,error,iter,currentPos]=Demo(x,y,z);
moverRobot(ardu,newConfig,0,1);
```
Donde el 0 en el tercer argumento de moverRobot indica que es un punto y no una trayectoria y el cuarto argumento indica que es un solo punto. Además, la variable error da el error que se espera de la simulación, la variable iter, el nº de iteraciones que ha tenido que hacer la simulación.

* Para llevar el robot a la posición inicial:
```matlab
calibrarRobot(ardu,2,1);
```
* Para establecer la posición actual como la inicial:
```matlab
calibrarRobot(ardu,0,1); 	
```
