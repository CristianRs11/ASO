#!/bin/bash
#Na siguiente liña comprobamos si somos usuario root.
if [[ $EUID = 0 ]]
then
	#Na siguiente liña comprobamos si existe a carpeta onde imos gardar as copias de seguridade.
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
	#Na siguiente liña comprobamos si escribiu algún parámetro
	if [[ $# -eq 0 ]]
	then
		#Na siguiente liña sacamos o id de tódolos usuarios
		cat /etc/passwd | cut -d : -f 3 | grep -E "[0-9]{4,5}" | while read id
		do
			#Na siguiente liña facemos que non se lle faga copia de seguridade o usuario co seguinte id
			if [[ $id -eq 65534 ]]
			then
				echo -n ""
			else
				#Na siguiente liña creamos unha variable co nome do usuario que teña o id que temos nese momento
				us=$(cat /etc/passwd | grep -w "$id" | cut -d : -f 1)
				#Na siguiente liña creamos unha variable ca ruta do usuario que teña o id que temos nese momento
				ruta=$(cat /etc/passwd | grep -w "$id" | cut -d : -f 6)
				#Na siguiente liña comprobamos si existe a carpeta co nome do noso usuario na carpeta de copiaSeg
				if [[ -d /copiaSeg/$us ]]
				then
					#Na siguiente liña comprimimos todo o do usuario na súa carpeta que está en copiaSeg
					tar -cf /copiaSeg/$us/copiaSeg.tar $ruta
				else 
					mkdir /copiaSeg/$us
					tar -cf /copiaSeg/$us/copiaSeg.tar $ruta
				fi
			fi
		done
	else
		#Na siguiente liña comprobamos si o primer parámetro é "-u"
		if [[ $1 == "-u" ]]
		then
			#Na siguiente liña creamos unha variable co segundo parámetro
			us=$(cat /etc/passwd | grep -w $2 | cut -d : -f 1)
			#Na siguiente liña comprobamos si existe o usuario que puxeron no segundo parámetro
			if [[ $us == $2 ]]
			then
				#Na siguiente liña comprobamos si existe o ficheiro .copiaSeg.dat na raíz do usuario
				if [[ -f /home/$us/.copiaSeg.dat ]]
				then
					#Na siguiente liña buscamos no fichiero si escribiron os directorios e ficheiros ós que lle queren facer a 
					#copia de seguridade e sepáraos cambiando ":" por " " e metémolo nunha variable
					ficheiro=$(fgrep "contidoCopia=" /home/$us/.copiaSeg.dat | cut -d = -f2 | tr ":" " " )
					#Na siguiente liña comprobamos si esa variable é nula
					if [[ -z $ficheiro ]]
					then
						echo -e "\e[1;31mA sintaxis é incorrecta\e[0m"
						echo -e "\e[1;36mA sintaxis é:\e[0m"
						echo -e "\e[1;36m#Copias que se desexan manter\e[0m"
						echo -e "\e[1;36mNumero Copias =2\e[0m"
						echo -e "\e[1;36m#Contido da copia, único obligatorio\e[0m"
						echo -e "\e[1;36mcontidoCopia=dir1:dir2:ficheiro1:ficheiro2,,.\e[0m"
					else
						#Na siguiente liña comprobamos si existe a carpeta co nome do noso usuario na carpeta de copiaSeg
						if [[ -d /copiaSeg/$us ]]
						then
							echo -e "\e[1;36mA carpeta /copiaSeg/$us existe\e[0m"
						else
							mkdir /copiaSeg/$us
						fi
						#Na siguiente liña imos crear unha carpeta temporal dentro de cada usuario para facer a copia de seguridade
						mkdir /copiaSeg/$us/copia
						#Na siguiente liña creamos unha variable na que nos informa de cantas copias de seguridade quere o usuario
						ncopias=$(fgrep "Numero Copias=" /home/$us/.copiaSeg.dat | cut d- = -f 2)
						#Na siguiente liña comprobamos is esa variable é nula.
						if [[ -z $ncopias ]]
						then
							#Na siguiente liña creamos unha variable na que nos informe de cantas copias de seguridade hai na carpeta
							copiasac=$(ls -l /copiaSeg/$us | wc -l)
							#Na siguiente liña como a variable $ncopias é nula por defecto será "2" e comprobamos si a carpeta do usairo 
							#ten máis de 2 copias de seguridade
							if [[ $copiasac -lt 2 ]]
							then
								#Na siguiente liña imos facer un "for" para que vaia leendo os ficheiros e carpetas que o ususairo 
								#pideu que lle fixeramos a copia
								for i in $ficheiro
								do
									#Na siguiente liña creamos unha variable que colla o ficheiro que pedimos
									chisme=$(find /home/$us -name $i 2> /dev/null)
									echo $chisme
									#Na siguiente liña copiamos ese ficheiro e movémolo para a carpeta temporal
									cp -r $chisme /copiaSeg/$us/copia/$i 2> /dev/null
								done
								#Na siguiente liña movémonos á carpeta temporal
								cd /copiaSeg/$us/copia
								#Na siguiente liña comprimimos esa carpeta
								tar -cf /copiaSeg/$us/copiaSeg_$(date + %H_%M_%d_%m_%Y).tar *
								#Na siguiente liña saímos da carpeta temporal
								cd
								#Na siguiente liña borramos a carpeta temporal
								rm -r /copiaSeg/$us/copia 2> /dev/null
							else
								#Na siguiente liña creamos unha variable co número de copias que hai de máis na carpeta
								resu=$(expr $copiasac - $ncopias + 1)
								#Na siguiente liña ordenamos o contido da carpeta onde están as copias de seguridade por fecha máis vella quitamos 
								#o número de copias que sobren por arriba e borrámolas								
								ls -tr /copiaSeg/$us | sort | head -$resu | xargs rm -r
								#Na siguientes liñas imos facer o mesmo que fixemos na anterior
								for i in $ficheiro
								do
									chisme=$(find /home/$us -name $i 2> /dev/null)
									echo $chisme
									cp -r $chisme /copiaSeg/$us/copia/$i 2> /dev/null
								done
								cd /copiaSeg/$us/copia
								tar -cf /copiaSeg/$us/copiaSeg_$(date + %H_%M_%d_%m_%Y).tar *
								cd
								rm -r /copiaSeg/$us/copia 2> /dev/null
							fi
						else
							#Na siguiente liña facemos o mesmo que antes pero o único que cambia é que en vez de usar o valor por defecto "2" cambiámolo 
							#por o valor que nos dixo o usuario
							if [[ $copiasac -lt $ncopias ]]
							then
								for i in $ficheiro
								do
									chisme=$(find /home/$us -name $i 2> /dev/null)
									echo $chisme

									cp -r $chisme /copiaSeg/$us/copia/$i 2> /dev/null
								done
								cd /copiaSeg/$us/copia
								tar -cf /copiaSeg/$us/copiaSeg_$(date + %H_%M_%d_%m_%Y).tar *
								cd
								rm -r /copiaSeg/$us/copia 2> /dev/null
							else
								resu=$(expr $copiasac - $ncopias + 1 )
								ls -tr /copiaSeg/$us | sort | head -$resu | xargs rm -r
								for i in $ficheiro
								do
									chisme=$(find /home/$us -name $i 2> /dev/null)
									echo $chisme
									cp -r $chisme /copiaSeg/$us/copia/$i 2> /dev/null
								done
								cd /copiaSeg/$us/copia
								tar -cf /copiaSeg/$us/copiaSeg_$(date + %H_%M_%d_%m_%Y).tar *
								cd
								rm -r /copiaSeg/$us/copia 2> /dev/null
							fi
						fi
					fi
				else
					echo -e "\e[1;31mNon existe o ficheiro .copiaSeg.dat \e[0m"
				fi
			else
				echo -e "\e[1;31mNon existe ese usuairo \e[0m"
			fi
		else
			echo -e "\e[1;31mSintaxis incorrecta \e[0m"
			echo -e "\e[1;36mA sintaxis é: copiaSeg [-u usuario] \e[0m"
		fi
	fi
else
	echo -e "\e[1;31mNon eres usuario root\e[0m"
fi
