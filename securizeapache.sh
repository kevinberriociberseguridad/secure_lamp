#! /bin/bash
#! /usr/sbin/a2dismod 

# En este archivo se realizarán las comprobaciones de PHP.

ficheroReal="/etc/apache2/apache2.conf"
ficheroPrueba="sandbox/apache2/apache2.conf"
ficheroReal2="/etc/apache2/envvars"
ficheroPrueba2="sandbox/apache2/envvars"
ficheroReal3="/etc/apache2/conf-available/security.conf"
ficheroPrueba3="sandbox/apache2/security.conf"

ficheroReal=$ficheroPrueba
ficheroReal2=$ficheroPrueba2
ficheroReal3=$ficheroPrueba3

echo
echo "##################################################"
echo
echo "Comprobación del usuario y grupo de ejecución"
echo
echo "##################################################"
echo

echo "Comprobación de usuario: "
echo

grep "^User.*\${.*}" $ficheroReal >> /dev/null
if [[ $? -ne 0 ]]
then
	cadenaNegacion=$(grep "^User.*" $ficheroReal)
	cadenaNegacion2=$(echo ${cadenaNegacion#*User })
	if [[ $cadenaNegacion2 != "www-data" ]]
	then
		echo "No se le ha asignado ningún parámetro a la variable de entorno."
		echo
		echo "El nombre del usuario es: $cadenaNegacion2"
		echo
		echo "ADVERTENCIA: El nombre de usuario utilizado no es un nombre recomendado."
  		echo "Se recomienda su sustitución."
  		echo
	fi
else
	echo "La variable de entorno tiene una configuración dinámica."
	echo
	#Saco el parámetro de la variable de entorno.
	cadena=$(grep "^User.*" $ficheroReal | grep "\${.*}")
	cadena1=$(echo ${cadena#*\{})
	cadena2=$(echo ${cadena1%\}*})
	cadenaVariable=$(grep "^export.*${cadena2}.*=.*" $ficheroReal2)
	nombreVariable=$(echo ${cadenaVariable#*\=})
	echo "El nombre de usuario asignado a la variable de entorno es: $nombreVariable"
	echo 
	if [[ $nombreVariable != "www-data" ]]; 
	then
  		echo "ADVERTENCIA: El nombre de usuario utilizado no es un nombre recomendado."
  		echo "Se recomienda su sustitución."
  	else
  		echo "El nombre de usuario: $nombreVariable, es un nombre de usuario totalmente recomendado."
	fi
	echo
fi

echo "--------------------------------------------------"
echo
echo "Comprobación de grupo: "
echo

grep "^Group.*\${.*}" $ficheroReal >> /dev/null
if [[ $? -ne 0 ]]
then
	cadenaNegacion=$(grep "^Group.*" $ficheroReal)
	cadenaNegacion2=$(echo ${cadenaNegacion#*Group })
	if [[ $cadenaNegacion2 != "www-data" ]]
	then
		echo "No se le ha asignado ningún parámetro a la variable de entorno."
		echo
		echo "El nombre del grupo es: $cadenaNegacion2"
		echo
		echo "ADVERTENCIA: El nombre de grupo utilizado no es un nombre recomendado."
  		echo "Se recomienda su sustitución."
  		echo
	fi
else
	echo "La variable de entorno tiene una configuración dinámica."
	echo
	#Saco el parámetro de la variable de entorno.
	cadena=$(grep "^Group.*" $ficheroReal | grep "\${.*}")
	cadena1=$(echo ${cadena#*\{})
	cadena2=$(echo ${cadena1%\}*})
	cadenaVariable=$(grep "^export.*${cadena2}.*=.*" $ficheroReal2)
	nombreVariable=$(echo ${cadenaVariable#*\=})
	echo "El nombre del grupo asignado a la variable de entorno es: $nombreVariable"
	echo 
	if [[ $nombreVariable != "www-data" ]]; 
	then
  		echo "ADVERTENCIA: El nombre del grupo utilizado no es un nombre recomendado."
  		echo "Se recomienda su sustitución."
  	else
  		echo "El nombre del grupo: $nombreVariable, es un nombre del grupo totalmente recomendado."
	fi
	echo
fi

# ####################################################################### #
# Deshabilitar módulos innecesarios
echo
echo "##################################################"
echo
echo "Deshabilitar módulos innecesarios"
echo
echo "##################################################"
echo
#Introduzco los módulos habilitados en una variable.
comando=$(sudo apachectl -M)
#Busco autoindex en la variable.
grep "autoindex.*" <<< $comando

if [[ $? -ne 0 ]]
then
	echo "todo bien todo bien, viviremos gracias Diego y David Bisbal"
	echo "El módulo está deshabilitado."
	echo
else
	echo "todo mal todo mal, vamos a morir"
	read -p "El módulo 'autoindex' está habilitado. ¿Desea deshabilitarlo? [ s / n ] " respuesta
	while [[ $respuesta != s ]] && [[ $respuesta != n ]];
	do
		read -p "Introduzca una opción correcta. [ s / n ] " respuesta
	done
	if [[ "$respuesta" = "s" ]]
	then
		echo
		echo "El módulo se está deshabilitando..."
		sudo a2dismod autoindex <<< "Yes, do as I say!"
		echo "El módulo 'autoindex' se ha deshabilitado con exito."
		echo
		read -p "Para hacer efectivo el cambio, se debe reiniciar el servicio de apache. ¿Desea reiniciarlo ahora? [ s / n ] " respuesta
		while [[ $respuesta != s ]] && [[ $respuesta != n ]];
		do
			read -p "Introduzca una opción correcta. [ s / n ] " respuesta
		done
		if [[ "$respuesta" = "s" ]]
		then
			echo "El servicio se está reiniciando..."
			sudo service apache2 restart
			echo "El servicio se ha reiniciado con exito."
		else
			echo "Ok, no se reiniciará el servicio."
		fi
	else
		echo "Ok, se pasará a la siguiente comprobación."
	fi
fi

# ####################################################################### #
# Ocultar información del servidor
echo
echo "##################################################"
echo
echo "Ocultar información del servidor"
echo
echo "##################################################"
echo
cambios=0
echo "Se va a comprobar la configuración de las directivas ServerTokens y ServerSignature."
echo
echo "Comprobación de la directiva ServerTokens: "
grep "^ServerTokens.*OS" $ficheroReal3 >> /dev/null
if [[ $? -ne 0 ]]
then
	echo
	echo "La directiva está configurada de forma segura."
	estado=$(grep "^ServerTokens.*" $ficheroReal3)
	echo "El estado actual de la directiva es: $estado."	
else
	echo
	echo "La directiva no está configurada de forma segura."
	estado=$(grep "^ServerTokens.*" $ficheroReal3)
	echo "El estado actual de la directiva es: $estado."
	read -p "¿Desea cambiar el estado de la directiva a 'ServerTokens ProductOnly'? [ s / n ] " respuesta
	while [[ $respuesta != s ]] && [[ $respuesta != n ]];
	do
		read -p "Introduzca una opción correcta. [ s / n ] " respuesta
	done
	if [[ "$respuesta" = "s" ]]
	then
		echo
		echo "La configuración de la directiva se está modificando..."
		sed -i 's/ServerTokens.*OS/ServerTokens ProductOnly/' $ficheroReal3 >> /dev/null
		echo "La configuración de la directiva se ha modificado con exito."
		cambios=1
	else
		echo "Ok, se pasará a la siguiente comprobación."
	fi
fi
echo
echo "--------------------------------------------------"
echo 
echo "Comprobación de la directiva ServerSignature: "
grep "^ServerSignature.*On" $ficheroReal3 >> /dev/null
if [[ $? -ne 0 ]]
then
	echo
	echo "La directiva está configurada de forma segura."
	estado=$(grep "^ServerSignature.*" $ficheroReal3)
	echo "El estado actual de la directiva es: $estado."	
else
	echo
	echo "La directiva no está configurada de forma segura."
	estado=$(grep "^ServerSignature.*" $ficheroReal3)
	echo "El estado actual de la directiva es: $estado."
	read -p "¿Desea cambiar el estado de la directiva a 'ServerSignature Off'? [ s / n ] " respuesta
	while [[ $respuesta != s ]] && [[ $respuesta != n ]];
	do
		read -p "Introduzca una opción correcta. [ s / n ] " respuesta
	done
	if [[ "$respuesta" = "s" ]]
	then
		echo
		echo "La configuración de la directiva se está modificando..."
		sed -i 's/ServerSignature.*On/ServerSignature Off/' $ficheroReal3 >> /dev/null
		echo "La configuración de la directiva se ha modificado con exito."
		cambios=1
	else
		echo "Ok, se pasará a la siguiente comprobación."
	fi
fi
echo
if [[ $cambios -eq 1 ]]
then
	read -p "Para hacer efectivo los cambios, se debe reiniciar el servicio de apache. ¿Desea reiniciarlo ahora? [ s / n ] " respuesta
	while [[ $respuesta != s ]] && [[ $respuesta != n ]];
	do
		read -p "Introduzca una opción correcta. [ s / n ] " respuesta
	done
	if [[ "$respuesta" = "s" ]]
	then
		echo "El servicio se está reiniciando..."
		sudo service apache2 restart
		echo "El servicio se ha reiniciado con exito."
	else
		echo "Ok, no se reiniciará el servicio."
	fi
fi
exit 0
