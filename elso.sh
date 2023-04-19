#!/bin/bash

# remark

#dir listázása
ls -l

#kivagyok
whoami


echo \$0: #ez a változó a környezeti változók 0. eleme lesz, vagyis a program neve!
echo $0

echo \$1: #első beadott paraméter ami szóközzel van elválasztva a program név hívása után
echo $1

echo \$2:
echo $2

echo \$#: # beadott paraméterek darabszáma? asszem! 
echo $#

#SZÁM ALAPÚ LOGIKA:
#kisebb : -lt   (less then)
#nagyobb: -gt   (greater then)
#kisebb vagy egyenlő:  -le  (less or equal)
#nagyobb vagy egyenlő: -ge  (greater or equal)
#nem  egyenlő? : ! a feltétel elé!             Figyelem: NEM SZABAD EGYBEÍRNI!!! 
#				   	pl:    !$# -eq 2 ---> nem fog műküdni  !
#					      ! $# -eq 2 ---> működni fog      !

#FILE ALAPÚ LOGIKA:
# -f filenév
# -r olvasható  -w   -x

#SZÖVEG ALAPÚ VIZSGÁLATOK:
#  =
# !=     itt műküdik egyben a nem egyenlő! Azért működik itt mert az előzőnél is 
#	 szövegként értelmezte, pedig szám volt, de ittt ez a cél...
#

if [ $# -eq 2 ]  #itt se szabad hogy hozzálrjen a ']' a ketteshez!!
then 
	echo "két paramétert ($1, $2) kaptam, a program indul."
else
	echo "Usage: $0 A B"
	echo "A: első paraméter"
	echo "B: második paraméter"
	exit
fi	

# a végén ha minden jól futott le, akkor 0-ás hibakóddal kell visszatérnie a dolognak!
echo 0

