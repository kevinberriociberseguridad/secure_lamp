#! /bin/bash

# En este archivo se realizarán las comprobaciones de PHP.

ficheroReal="/etc/apache2/apache2.conf"
ficheroPrueba="sandbox/apache2/apache2.conf"
ficheroReal2="/etc/apache2/envvars"
ficheroPrueba2="sandbox/apache2/envvars"

ficheroReal=$ficheroPrueba
ficheroReal2=$ficheroPrueba2

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
	echo "No se le ha asignado ningún parámetro a la variable de entorno."
	echo
	echo "se le asignará por defecto el usuario: www-data"
	sed -i 's/^User.*/User www-data/' $ficheroReal
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
	echo "No se le ha asignado ningún parámetro a la variable de entorno."
	echo
	echo "se le asignará por defecto el grupo: www-data"
	sed -i 's/^Group.*/Group www-data/' $ficheroReal
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

