
# Toma de datos

Esta carpeta contiene el codigo empleado para tomar datos del comportamiento del robot, los .xls con los datos obtenidos y el codigo empleado para el tratamiento de datos.



### Instalacion
Para ejecutar el codigo para la toma de datos en matlab hay que tener instalado ROS (y en concreto el paquete ros_kinetic_vrpn_client_ros) y el add-on ROS Toolbox de Matlab (disponible a patir de Matlab2019).

La version de Ros empleada en este caso ha sido Kinetic, pero deberia valer tambien Melodic sin hacer apenas cambios. 

El ordenador desde el que se transmiten los datos tiene que tener la opcion de transmision de datos mediante VRPN de Optitrack. Es aconsejable revisar la mascara del ordenador que recibe los datos y que ninguno de ellos esta conectado a internet.

### Uso
Los archivos de la toma de datos corresponden cada uno a un experimento diferente y viene indicado en su nombre que motores del robot se mueven en cada uno.

Al principio de estos archivos se establece la conexion con Arduino con un Baudrate de 11520, asi que hay que modificar el puerto y el Baudrate (si fuera necesario) para usarlos.

Despues se inicializa la conexion de ros y se suscribe al topic deseado. Para ello se le pasa a la funcion rosinit la IP del ordenador que transmite los datos y el puerto desde el que lo hace, por lo que habra que modificar los valores para usarlos con otro ordenador.
La funcion receive captura todos los datos que transmite el topic elegido cada vez que se ejecuta pero hay que indicarle que margen de tiempo puede tardar como maximo en recibir un dato antes de dar error. Este valor se puede modificar segun se requiera (aumentarlo puede hacer que se tarde mÃ¡s en tomar los datos pero si la conexion es lenta o la frecuencia de transmision de datos baja, puede ser necesario aumentarlo).

Se usa la funcion writematrix para volcar en un .xls cuyo nombre se debe indicar (funciona con mas formatos) tanto los datos que se quiere guardar como el header para indicar que son (se puede modificar segun resulte mas comodo). Se hace usando append para que siempre coloque los datos nuevos en la linea de debajo de los que ya hay pero existen mas opciones.

Dentro del bucle se mueven los motores y se capturan los datos de su posicion despues de cada mmovimiento. 
Al final se devuelve el robot a su posicion de reposo y se cierra la conexion con Arduino.

El archivo transformador_optitrack.m transforma la orientacion de la posicion del robot que se le pasa a angulos de Euler y encuentra la matriz de transformacion para hacer el cambio de sistema de referencia del del optitrack al del robot (MTH). 
Y el archivo transf_dat.m ejecuta el archivo transformador_optitrack.m con los datos del robot en la posicion de reposo (que se le pasa en la variable ini) y usa la matriz obtenida para transformar todos los datos que se le pasan (en la variable data) y los vuelca en otro .xls.
