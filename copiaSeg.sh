#!/bin/bash
# Arreglar todo a partir da 53
if [[ $EUID = 0 ]]
then
	if [[ -d /copiaSeg ]]
	then
		echo -e "\e[1;36mComprobando se a carpeta /copiaSeg existe...\e[0m"
		echo -e "\e[1;36mA carpeta /copiaSeg existe\e[0m"
		echo -n ""
	else
		echo -e "\e[1;36mComprobando se a carpeta /copiaSeg existe...\e[0m"
		echo -e "\e[1;31mA carpeta /copiaSeg non existe\e[0m"
		echo -e "\e[1;36mCreando a carpeta...\e[0m"
		mkdir /copiaSeg
	fi
	if [[ $# -eq 0 ]]
	then
		cat /etc/passwd | cut -d : -f 3 | grep -E "[0-9]{4,5}" | while read id
		do
			if [[ $id -eq 65534 ]]
			then
				echo -n ""
			else
				us=$(cat /etc/passwd | grep -w "$id" | cut -d : -f 1)
				ruta=$(cat /etc/passwd | grep -w "$id" | cut -d : -f 6)
				if [[ -d /copiaSeg/$us ]]
				then
					tar -cf /copiaSeg/$us/$ruta
				else 
					mkdir /copiaSeg/$us
					tar -cf /copiaSeg/$us/$ruta
				fi
			fi
		done
	else
		if [[ $1 == "-u" ]]
		then
			us=$(cat /etc/passwd | grep -w $2 | cut -d : -f 1)
			if [[ $us == $2 ]]
			then
				if [[ -f /home/cristian/.copiaSeg.dat ]]
				then
					ficheiro=$(fgrep "contidoCopia=" /home/cristian/.copiaSeg.dat | cut -d = -f2 | tr ":" " " )
					if [[ -z $ficheiro ]]
					then
						echo -e "\e[1;31mA sintaxis é incorrecta\e[0m"
						echo -e "\e[1;36mA sintaxis é:\e[0m"
						echo -e "\e[1;36m#Copias que se desexan manter\e[0m"
						echo -e "\e[1;36mNumero Copias =2\e[0m"
						echo -e "\e[1;36m#Contido da copia, único obligatorio\e[0m"
						echo -e "\e[1;36mcontidoCopia=dir1:dir2:ficheiro1:ficheiro2,,.\e[0m"
					else
						mkdir /home/cristian/copias/copia
						for i in $ficheiro
						do
							chisme=$(find /home/cristian/ -name $i 2> /dev/null)
							echo $chisme

							cp -r $chisme /home/cristian/copias/copia/$i 2> /dev/null
						done
						cd /home/cristian/copias/copia
						tar -cf /home/cristian/copias/copia.tar *
						cd
						rm -r /home/cristian/copias/copia 2> /dev/null
					
				else
					echo "Non existe"
				fi
			else
				echo "Non existe ese usuairo"
			fi
		else
			echo -e "\e[1;31mSintaxis incorrecta \e[0m"
			echo -e "\e[1;36mA sintaxis é: copiaSeg [-u usuario] \e[0m"
		fi
	fi
else
	echo -e "\e[1;31mNon eres usuario root\e[0m"
fi