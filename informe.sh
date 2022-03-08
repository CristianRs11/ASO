#!/bin/bash
# {} significa que executa un a un cada ficheiro e \; significa que acaba aí o comando -exec
#Comprobamos si non se puxo nada nos parámetros
if [[ $# -eq 0 ]]
then
	#Creamos unha variable que conteña a tódolos usuarios
	usus=$(cut -d: -f1 /etc/passwd)
	#Separamos cada usuario e metémolo na variable $usu
	for usu in $usus
	do
		#Comprobamos si o usuario é root
		if [[ $usu == "root" ]]
		then
			echo " "
		else
			#Creamos unha variable na que se busca todos os ficheiros dentro da carpeta raíz do usuario e contámolos.
			fichpro=$( find /home/$usu -user $usu -type f 2> /dev/null | wc -l )
			#Creamos unha variable na que se busca todos os ficheiros dentro da carpeta raíz do usuario, que se executen con sudo, comprobamos que exista e teñan permiso de escritura e contámolos.
			fichmod=$( find /home/$usu -type f 2> /dev/null -exec sudo -u $usu test -w {}\; | wc -l )
			#Creamos unha variable na que busca todos os aquivos que están abertos polo usuario, ordenámolos, collemos a primeira columna, collemos un de cada sin repetilos e contámolos.
			fichabier=$( lsof -u $usu 2> /dev/null | sort | cut -d" " -f1 | uniq | wc -l )
			#Creamos unha variable na que busca todos os ficheiros e imprimeos coa fecha de creación, ordenámolos, collemos a primeira fila e collemos a segunda columna.
			fichant=$( find /home/$usu/ -user $usu -type f -printf "%T+ %f\n" 2> /dev/null | sort -n | head -1 | cut -d " " -f2 )
			#Creamos unha variable na que busca todos os ficheiros do usuario e executámolo co comando stat -c (o -c e para darlle o formato que escribimos co %y %n), ordenámolos, collemos a última file e collemos a cuarta columna.
			fichremod=$( find /home/$usu/ -user $usu -type f -exec stat -c "%y %n" {} 2> /dev/null \; | sort -n | tail -1 | cut -d " " -f4 )
			#Creamos 
			fichchikito=$( find /home/uadmin/ -user uadmin -type f -exec stat -t {} \; 2>/dev/null | cut -d " " -f 1,2 | sort -n -t" " -k2 | head -n1 | cut -d" " -f2 )
			echo "#####################################################"
			echo "Usuairo: $usu"
			echo "Nº Ficheros de los que es propietario: $fichpro"
			echo "Nº Ficheros que puede modificar: $fichmod"
			echo "Nº Fichero abiertos: $fichabier"
			echo "Fichero más antiguo del usuario: $fichant" 
			echo "Fichero más recientemente modificado: $fichremod"
			echo "Tamaño fichero más pequeño: $fichchikito"
		fi
	done
else
		for usuario in $@
		do
			if [[ $usuario == $(cut -d: -f1 /etc/passwd | fgrep $usuario | head -n1) ]]
			then
				echo -e "\e[1;36mEse é un usuairo \e[0m"
			else
				echo -e "\e[1;31mNon existe ese usuario \e[0m"
			fi
		done
fi
