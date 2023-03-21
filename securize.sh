#! /bin/bash

sed 's/^bind-address.*=.*127.0.0.1$/bind-address=0.0.0.0/' mysqld.cnf
# Ruta real --> /etc/mysql/mysql.conf.d/mysqld.cnf
if [[ $? -eq 0 ]]
then 
	echo "Se ha realizado correctamente la modificación."
else 
	echo "Error, no se ha podido realizar la modificación."
fi
