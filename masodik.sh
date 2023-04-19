#!/bin/bash

function hello
{
	echo "hello" $1
	echo "A fv. elso argumentuma: $1"	# ez itt a program belseje felől hívott argumentum! azaz Dávid!
}

hello Dávid

function kilep
{
	exit
}

echo "Az elso argumentum: $1"  #ez itt a külvilág felől kapott argumentum!
hello $1		       #ez már a külvilág felől kapott argumentum hívása a hello függvénybe! továbbadva!
kilep
echo $2 	#ide már nem fog eljutni a kilép function után mert kilép a srciptből az exit-el



