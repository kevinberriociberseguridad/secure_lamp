#! /bin/bash

# En este archivo se realizarán las comprobaciones de PHP.

ficheroReal="/etc/php/8.1/apache2/php.ini"
ficheroPrueba="sandbox/php.ini"

ficheroReal=$ficheroPrueba

# 1. Comprobación de la configuración del parámetro "expose_php"
echo
echo "Comprobación de la configuración del parámetro 'expose_php'." 

#Comprobamos si existe la configuración está de esta manera: "expose.php = Off"
echo "Estado actual del parámetro: ";grep "expose_php.*=.*" $ficheroReal

#Si no esta en "Off", se modifica.
if [[ $? -ne 0 ]]
then
	echo "expose_php = Off" >> $ficheroReal
else
	grep "expose_php.*=.*Off" $ficheroReal >> /dev/null
	if [[ $? -ne 0 ]]
	then
		sed -i 's/expose_php.*=.*On/expose_php = Off/' $ficheroReal >> /dev/null
		echo "El parámetro se ha modificado."
		echo "Estado del parámetro tras la modificación: ";grep "expose_php.*=.*Off" $ficheroReal
	fi
fi

# 2. Comprobación de la configuración del parámetro "display_errors"
echo 
echo "Comprobación de la configuración del parámetro 'display_errors'." 

#Comprobamos si existe la configuración está de esta manera: "display_errors = Off"
echo "Estado actual del parámetro: ";grep "^display_errors.*=.*" $ficheroReal

#Si no esta en "Off", se modifica.
if [[ $? -ne 0 ]]
then
	echo "display_errors = Off" >> $ficheroReal
else
	grep "^display_errors.*=.*Off" $ficheroReal >> /dev/null
	if [[ $? -ne 0 ]]
	then
		sed -i 's/^display_errors.*=.*On/display_errors = Off/' $ficheroReal >> /dev/null
		echo "El parámetro se ha modificado."
		echo "Estado del parámetro tras la modificación: ";grep "^display_errors.*=.*Off" $ficheroReal
	fi
fi

# 3. Comprobación de la configuración del parámetro "open_basedir"
echo 
echo "Comprobación de la configuración del parámetro 'open_basedir'." 

#Comprobamos el estado del parámetro: "open_basedir"
echo "Estado actual del parámetro: ";grep "^;open_basedir.*=.*" $ficheroReal

#Si está activo.
if [[ $? -ne 0 ]]
then
	echo "Esta es la configuración del parámetro: ";grep "open_basedir.*=.*" $ficheroReal
	echo "El parámetro 'open_basedir' está activo."
else
	echo "El parámetro open_basedir está inactivo."	// Hecha por Diego Gay Sáez, con cariño para Kevin.
	read -p "¿Quiere activar el parámetro 'open_basedir'? " activarParametro
	while [[ $activarParametro != s ]] && [[ $activarParametro != n ]];
	do
		read -p "Introduzca una opción correcta. [ s / n ] " activarParametro
	done
	if [[ "$activarParametro" = "s" ]]
	then
		read -p "Introduzca que ruta quiere añadir al parámetro 'open_basedir' " ruta
		while [ ! -d $ruta ];
		do
			read -p "Introduzca una ruta válida: " ruta
		done
		sed -i "s#^;open_basedir.*=.*#open_basedir = ${ruta}#" $ficheroReal >> /dev/null
		echo "El parámetro se ha modificado."
		echo "Estado del parámetro tras la modificación: ";grep "^open_basedir.*=.*" $ficheroReal
	fi
fi












































exit 0
