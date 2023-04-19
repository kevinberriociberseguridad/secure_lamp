#! /bin/bash
function comprobarFichero() {
	local nuevoFichero=""
	if [[ ! -f $1 ]]
	then
		echo "Se esperaba encontrar el fichero de configuración $1"
		echo "Si ese no es el fichero correcto, por favor, indíquelo a continuación."
		until [ ! -f $nuevoFichero ]
		do
			read -p "Ruta completa: " nuevoFichero
		done
	fi
}

function avisoMYSQL() {
	permisos=""
	echo -e "\nAVISO: La siguiente modificación la debe de hacer un usuario con permisos. Si no los posee, pase a la siguiente comprobación."
	read -p "¿Es usted un usuario con permisos para realizar esta modificación? [ s / n ] " permisos
	while [[ $permisos != s ]] && [[ $permisos != n ]];
	do
		read -p "Introduzca una opción correcta. [ s / n ] " permisos
	done
	if [ $permisos == s ]
	then
		read -p "Introduzca el usuario de mysql: " usuario
		read -p "Introduzca la contraseña de mysql: " contrasena
		read -p "Introduzca el nombre de la base de datos: " nombreBD
		read -p "Introduzca el nuevo nombre para el usuario: " nusuario
		#Esta función contiene las comprobaciones MYSQL
		comprobacionesMYSQL
	else
		echo "Okey, se pasará a la siguiente comprobación."
	fi
}

function preguntaConsulta() {
	preguntaComprobacion=""
	echo -e "\nAVISO: La siguiente modificación la debe de hacer un usuario con permisos. Si no los posee, pase a la siguiente comprobación."
	read -p "¿Quiere realizar la siguiente comprobación [ $1 ]? [ s / n ] " preguntaComprobacion
	while [[ $preguntaComprobacion != s ]] && [[ $preguntaComprobacion != n ]];
	do
		read -p "Introduzca una opción correcta. [ s / n ] " preguntaComprobacion
	done
}

function comprobacionesMYSQL() {
	# 3. Renombrar el usuario root

	echo 
	echo "##### RENOMBRAR EL USUARIO ROOT #####"
	echo

	titulo="RENOMBRAR_EL_USUARIO_ROOT"
	#Esta función realiza la consulta en MYSQL
	preguntaConsulta $titulo
	if [ $? -eq 0 ]
	then		
		mysql -u$usuario -p$contrasena << EOF
			use $nombreBD;
			update mysql.user set user='$nusuario' where user='root'; 
			flush privileges;
			exit
EOF
	else
		echo "Okey, se pasará a la siguiente comprobación."
	fi

	# 4. Evitar usuario anónimos

	echo 
	echo "##### EVITAR USUARIOS ANÓNIMOS #####"
	echo

	titulo="EVITAR_USUARIOS_ANÓNIMOS"
	preguntaConsulta $titulo
	if [ $? -eq 0 ]
	then
		echo
		echo "Número de usuarios anónimos: " 
		mysql -u$usuario -p$contrasena << EOF
			use $nombreBD;
			select count(user) as "Número de usuarios anónimos" FROM mysql.user WHERE user="" OR user ="test";
			#select user, host FROM mysql.user WHERE user="" OR user ="test";
			exit		
EOF
	else
		echo "Okey, se pasará a la siguiente comprobación."
	fi

	# 5. Controlar los privilegios de los usuarios

	echo 
	echo "##### CONTROLAR LOS PRIVILEGIOS DE LOS USUARIOS #####"
	echo

	titulo="CONTROLAR_LOS_PRIVILEGIOS_DE_LOS_USUARIOS"
	preguntaConsulta $titulo
	if [ $? -eq 0 ]
	then		
		mysql -u$usuario -p$contrasena << EOF
			use $nombreBD;
			select distinct(grantee) from information_schema.user_privileges;
			exit
EOF
	else
		echo "Okey, se pasará a la siguiente comprobación."
	fi
	#echo -p "Con los resultados de esa consulta, se pueden hacer consultas específicas sobre cada usuario. ¿Deasea realizarlas? [ si / no ] " permisos
}

# 1. Evitar conexiones remotas

echo 
echo "##### EVITAR CONEXIONES REMOTAS #####"
echo

ficheroReal="/etc/mysql/mysql.conf.d/mysqld.cnf"
ficheroPrueba="sandbox/mysqld.cnf"
permisos=""

ficheroReal=$ficheroPrueba

sed -i 's/^bind-address.*=.*0.0.0.0$/bind-address = 127.0.0.1/' $ficheroReal
if [[ $? -eq 0 ]]
then 
	echo "Se ha realizado correctamente la modificación."
	grep bind-address $ficheroReal
else 
	echo "Error, no se ha podido realizar la modificación."
fi

# 2. Evitar acceso al sistema desde MySQL

echo 
echo "##### EVITAR ACCESO AL SISTEMA DESDE MYSQL #####"
echo

ficheroReal2="/etc/mysql/my.cnf"
ficheroPrueba2="sandbox/my.cnf"

ficheroReal2=$ficheroPrueba2

grep "\[mysqld\]" $ficheroReal2 > /dev/null

if [[ $? -eq 0 ]]
then
	grep local-infile $ficheroReal2 > /dev/null
	if [[ $? -eq 0 ]]
	then 
		echo "Se ha realizado correctamente la comprobación."
	else
		echo "" >> $ficheroReal2
		echo "local-infile = 0" >> $ficheroReal2
		echo "secure-file-priv = /dev/null" >> $ficheroReal2
		echo "Se ha realizado correctamente la modificación."
	fi
else 
	echo "" >> $ficheroReal2
	echo "[mysqld]" >> $ficheroReal2
	echo "" >> $ficheroReal2
	echo "local-infile = 0" >> $ficheroReal2
	echo "secure-file-priv = /dev/null" >> $ficheroReal2
	echo "Se ha realizado correctamente la modificación."
fi

##### PARTE MYSQL ##### 
#Con esta función compruebo, si el ususario tiene permisos para realizar las comprobaciones en MYSQL

avisoMYSQL

# 6. 

exit 0
