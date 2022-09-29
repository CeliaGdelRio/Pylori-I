
# Toma de datos

Esta carpeta contiene el cÃ³digo empleado para tomar datos del comportamiento del robot, los .xls con los datos obtenidos y el cÃ³digo empleado para el tratamiento de datos.



### InstalaciÃ³n
Para ejecutar el cÃ³digo para la toma de datos en matlab hay que tener instalado ROS (y en concreto el paquete ros_kinetic_vrpn_client_ros) y el add-on ROS Toolbox de Matlab (disponible a patir de Matlab2019).

La versiÃ³n de Ros empleada en este caso ha sido Kinetic, pero deberÃ­a valer tambiÃ©n Melodic sin hacer apenas cambios. 

El ordenador desde el que se transmiten los datos tiene que tener la opciÃ³n de transmisiÃ³n de datos mediante VRPN de Optitrack. Es aconsejable revisar la mÃ¡scara del ordenador que recibe los datos y que ninguno de ellos estÃ© conectado a internet.

### Uso
Los archivos de la toma de datos corresponden cada uno a un experimento diferente y viene indicado en su nombre que motores del robot se mueven en cada uno.

Al principio de estos archivos se establece la conexiÃ³n con Arduino con un Baudrate de 11520, asÃ­ que hay que modificar el puerto y el Baudrate (si fuera necesario) para usarlos.

DespuÃ©s se inicializa la conexiÃ³n de ros y se suscribe al topic deseado. Para ello se le pasa a la funciÃ³n rosinit la IP del ordenador que transmite los datos y el puerto desde el que lo hace, por lo que habrÃ­a que modificar los valores para usarlos con otro ordenador.
La funciÃ³n receive captura todos los datos que transmite el topic elegido cada vez que se ejecuta pero hay que indicarle que margen de tiempo puede tardar como mÃ¡ximo en recibir un dato antes de dar error. Este valor se puede modificar segÃºn se requiera (aumentarlo puede hacer que se tarde mÃ¡s en tomar los datos pero si la conexiÃ³n es lenta o la frecuencia de transmision de datos baja, puede ser necesario aumentarlo).

Se usa la funciÃ³n writematrix para volcar en un .xls cuyo nombre se debe indicar (funciona con mÃ¡s formatos) tanto los datos que se quiere guardar como el header para indicar que son (se puede modificar segÃºn resulte mÃ¡s cÃ³modo). Se hace usando append para que siempre coloque los datos nuevos en la lÃ­nea de debajo de los que ya hay pero existen mÃ¡s opciones.

Dentro del bucle se mueven los motores y se capturan los datos de su posiciÃ³n despues de cada mmovimiento. 
Al final se devuelve el robot a su posiciÃ³n de reposo y se cierra la conexiÃ³n con Arduino.

El archivo transformador_optitrack.m transforma la orientaciÃ³n de la posiciÃ³n del robot que se le pasa a Ã¡ngulos de Euler y encuentra la matriz de transformacion para hacer el cambio de sistema de referencia del del optitrack al del robot (MTH). 
Y el archivo transf_dat.m ejecuta el archivo transformador_optitrack.m con los datos del robot en la posiciÃ³n de reposo (que se le pasa en la variable ini) y usa la matriz obtenida para transformar todos los datos que se le pasan (en la variable data) y los vuelca en otro .xls.
