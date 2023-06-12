#!/bin/bash

#minMeret_XY=11
#enlarge=2
#aktualMeret_XY=$minMeret_XY
#counter=2

#aktualMeret_XY=$((aktualMeret_XY+enlarge*(counter+1)))

#printf "%s \n" "$aktualMeret_XY"

szelesseg=21
szoveghossz_fele=2
fele_pont=11

#echo -e  "clear; \033c\e[3J"        #képernyő letisztítása
#echo -en "\033[1A"                  #kocsi feljebb ugratása 1-el 
#echo -en "\033[1;0f"
#echo "1eee56eee01eee56eee01"

#<$((fele_pont-szoveghossz_fele))>

msg_egy="A terminálnak minimum\n"   
msg_ketto=" 34  magasság, \n"
msg_harom=" 64 szélesség  \n"
msg_negy="     kell!"

hossz_negy=$((10/2))
midWidth=11
n=${#msg_negy}

startPoz_negy=$((midWidth-(${#msg_negy}/2)))


printf "%s \n" "$startPoz_negy"