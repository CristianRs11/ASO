#!/bin/bash
if [[ $# -eq 0 ]]
then
	usus=$(cut -d: -f1 /etc/passwd)
	for usu in $usus
	do
		if [[ $usu == "root" ]]
		then
			echo " "
		else
			fichpro=$( find /home/$usu -user uadmin -type f 2> /dev/null | wc -l )
			echo "#####################################################"
			echo "Usuairo: $usu"
			echo "Nº Ficheros de los que es propietario: $fichpro"
			echo ""
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
