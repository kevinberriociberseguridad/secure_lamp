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

function comprobarPermisos() {
	echo "AVISO: La siguiente modificación la debe de hacer un susuario con permisos. Si no los posee, pase a la siguiente comprobación."
	read -p "¿Es usted un usuario con permisos para realizar esta modificación? [ si / no ] " permisos
	while [[ $permisos != si ]] && [[ $permisos != no ]];
	do
		read -p "Introduzca una opción correcta. [ si / no ] " permisos
	done
	if [ $permisos == si ]
	then
		read -p "Introduzca el usuario de mysql: " usuario
		read -p "Introduzca la contraseña de mysql: " contrasena
		read -p "Introduzca la contraseña de mysql: " nombreBD
		read -p "Introduzca el nuevo nombre para el usuario: " nusuario
		
		mysql -u $nombre -p $contrasena <<EOF
			use $nombreBD;
			$1
			exit;
		EOF
	else
		echo "Okey, se pasará a la siguiente comprobación."
	fi
}


# 1. Evitar conexiones remotas

ficheroReal="/etc/mysql/mysql.conf.d/mysqld.cnf"
ficheroPrueba="sandbox/mysqld.cnf"

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

# 3. Renombrar el usuario root

consulta=$(update mysql.user set user="$nusuario" where user="root"; flush privileges;)
comprobarPermisos $consulta

# 4. Evitar usuario anónimos

consulta=$(SELECT user, host FROM mysql.user WHERE user="" OR user ="test";)
comprobarPermisos $consulta

# 5. Controlar los privilegios de los usuarios



exit 0
