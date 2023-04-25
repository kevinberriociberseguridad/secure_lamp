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
grep "^;open_basedir.*=.*" $ficheroReal

#Si está activo.
if [[ $? -ne 0 ]]
then
	echo "Esta es la configuración del parámetro: ";grep "open_basedir.*=.*" $ficheroReal
	echo "El parámetro 'open_basedir' está activo."
else
	echo "Estado actual del parámetro: ";grep "^;open_basedir.*=.*" $ficheroReal
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

# 4. Comprobación de la configuración del parámetro "disable_functions"
activarParametro=""
echo 
echo "Comprobación de la configuración del parámetro 'disable_functions'." 

#Comprobamos el estado del parámetro: "disable_functions"
grep "^;disable_functions.*=.*" $ficheroReal >> /dev/null

#Si está activo.
if [[ $? -ne 0 ]]
then
	declare -i num=1
	echo "Esta es la configuración del parámetro: ";grep "^disable_functions.*=.*" $ficheroReal
	echo "El parámetro 'disable_functions' está activo."
	while [ $num != 0 ];
	do
		echo
		echo "########### MENÚ ###########"
		echo
		echo "1. Borrar las funciones."
		echo "2. Establecer funciones por defecto."
		echo "3. Establecer funciones por elección."
		echo "4. Deshabilitar la opción disable_functions"
		echo "5. Mostrar estado del parámetro 'disable_functions'"
		echo "0. Salir."
		echo
		echo "############################"
		echo
		read -p "Seleccione una opción: " opcion
		while [ $opcion -gt 5 ] && [ $opcion -lt 0 ];
		do
			read -p "Seleccione una opción correcta: [ 0 1 2 3 4 ]" opcion
		done
		case $opcion in
			0)
    				echo "Ha salido del menú de configuración de 'disable_functions' exitosamente."
    				num=0
  			;;
	  		1)
	  			echo "Borrando funciones..."
	    			sed -i 's/^disable_functions.*=.*/disable_functions = /' $ficheroReal >> /dev/null
	    			echo "Funciones borradas exitosamente."
	  		;;
  			2)
    				echo "Estableciendo funciones..."
	    			sed -i 's/^disable_functions.*=.*/disable_functions = phpinfo, system, exec, shell_exec, ini_set, dl, eval/' $ficheroReal >> /dev/null
	    			echo "Funciones establecidas exitosamente."
  			;;
  			3)
  				funciones=("phpinfo" "system" "exec" "shell_exec" "ini_set" "dl" "eval")
  				sed -i 's/^disable_functions.*=.*/disable_functions = /' $ficheroReal >> /dev/null
  				for funcion in "${funciones[@]}"
  				do
  					read -p "¿Quiere añadir la función: $funcion? [ s / n ] " insertarFuncion
					while [[ $insertarFuncion != s ]] && [[ $insertarFuncion != n ]];
					do
						read -p "Introduzca una opción correcta. [ s / n ] " insertarFuncion
					done
					if [[ "$insertarFuncion" = "s" ]]
					then
						comando=$(grep "^disable_functions.*=.*" $ficheroReal)
						lineaNueva="$comando, $funcion"
						sed -i "s#^disable_functions.*=.*#${lineaNueva}#" $ficheroReal >> /dev/null					
					else 
						echo "Ok, se omitirá la función: $funcion y se pasará a la siguiente función."
					fi
  				done
    				echo "Estableciendo funciones..."
	    			echo "Funciones establecidas exitosamente."
  			;;
  			4)
    				echo "Deshabilitando la opción disable_functions..."
    				comando=$(grep "^disable_functions.*=.*" $ficheroReal)
				lineaNueva=";$comando"
	    			sed -i "s#^disable_functions.*=.*#${lineaNueva}#" $ficheroReal >> /dev/null
	    			echo "Opción deshabilitada exitosamente."
  			;;
  			5)
    				estadoParametro=$(grep "^disable_functions.*=.*" $ficheroReal)
    				echo "Estado actual del parámetro 'disable_functions'-->  $estadoParametro"
  			;;
			*)
    				echo "Error."
  			;;
		esac
	done
else
	echo "El parámetro disable_functions está inactivo."
	read -p "¿Quiere activar el parámetro 'disable_functions'? " activarParametro
	while [[ $activarParametro != s ]] && [[ $activarParametro != n ]];
	do
		read -p "Introduzca una opción correcta. [ s / n ] " activarParametro
	done
	if [[ "$activarParametro" = "s" ]]
	then
		comando=$(grep "^;disable_functions.*=.*" $ficheroReal)
		lineaNueva="${comando:1}"
		sed -i "s#^;disable_functions.*=.*#${lineaNueva}#" $ficheroReal >> /dev/null
		echo "El parámetro se ha modificado."
		echo "Estado del parámetro tras la modificación: ";grep "^disable_functions.*=.*" $ficheroReal
	else
		echo "Ok, el parámetro 'disable_functions' permanecerá deshabilitada."
	fi
fi

exit 0
