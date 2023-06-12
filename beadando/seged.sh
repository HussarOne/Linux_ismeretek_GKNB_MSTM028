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

#msg_egy="A terminálnak minimum\n"   
#msg_ketto=" 34  magasság, \n"
#msg_harom=" 64 szélesség  \n"
#msg_negy="     kell!"

#hossz_negy=$((10/2))
#midWidth=11
#n=${#msg_negy}

#startPoz_negy=$((midWidth-(${#msg_negy}/2)))


#printf "%s \n" "$startPoz_negy"




#holder=$(tput cols)
#echo $holder
#szam=$(($(tput cols)-50))

#echo -en "\033[4;$((30-20))H" #works!!
#printf "%s \n" "$szam"
#echo -en "\033[4;$((szam-3))H" #works!!
#echo "1eee56eee01eee56eee01"


fix_X=12              #ideálisan a 2. karakterre szeretnénk helyezni mögé a kocsit 
startPos=8               #8 az első opció!
maxPos=12                #ennél tovább nem mehet
minPos=$startPos         #elején ez a minimum is
aktualPos=$startPos

echo -en "\033[5;$((fix_X))H"
read -rsn 1 char 
while [[ $char != "" ]]; do 
    #printf "%s /t" "${char[1]}"         #13 sor van 
    if [[ $char = "w" ]]; then
        if [[ $((aktualPos-1)) -ge minPos ]]; then
            aktualPos=$((aktualPos-1))          #pozíció értékének csökkentése, ha még tudunk felfele lépni!           
            echo -en "\033[$aktualPos;$((fix_X))H"      #visszalépés a 12-es X koordinátára ugyan abban a sorban
        fi
    fi

    if [[ $char = "s" ]]; then
        if [[ $((aktualPos+1)) -le maxPos ]]; then
            aktualPos=$((aktualPos+1))          #pozíció értékének csökkentése, ha még tudunk felfele lépni!           
            echo -en "\033[$aktualPos;$((fix_X))H"      #visszalépés a 12-es X koordinátára ugyan abban a sorban
        fi
    fi

    read -rsn 1 char
done