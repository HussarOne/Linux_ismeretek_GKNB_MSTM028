#!/bin/bash

echo -e  "clear; \033c\e[3J"         #képernyő letisztítása
echo -en "\033[1A"                   #kocsi feljebb ugratása 1-el 

width=$(tput cols)                   #megadja hány oszlopos a terminálunk
height=$(tput lines)                 #megadja hány    soros a terminálunk
                                     #továbbá: echo mentesen adja meg! nem kell törölni!

if [[ $height -lt 25 ]]; then
    midWidth=$((width/2))
    midHeight=$((height/2))

    msg="A terminálnak legalább "
fi

#pályatervek!
                          9    11    13    15    17
 ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ 
 ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ 
 ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ 
 ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ 
 ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ 

 █▋█▋█▋█▋█▋█▋█▋█▋█▋█▋█▋█▋█▋█▋█▋█▋█▋█▋█▋  


▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁
▏   ░░░░░░                                                            ▕
▏ ██░░██░░██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▕  
▏   ░░░░░░                                                            ▕ 
▏ ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▕
▏                                                                     ▕ 
▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
#név beolvasása
printf "Add meg a neved! \nneved: " 
read -r username

#pálya elkészítéshez információk
printf "\nNavigálni a W: felfele és S:lefele gombokkal lehet!"
printf "\nPályaméret választáshoz navigálj a kívánt számra és ENTER!"

printf "\n\nPályaméret lehetőségek:"
minMeret=11                         #pálya minimum mérete, szimmetrikus
enlarge=2                           #opcióknál ennyivel növeljük a méretet szimmetrikusan
aktualMeret=$minMeret               #ez az aktuális méret amit kiírunk választhatónak
for ((i=0; i < 5; i++)) 
do
    aktualMeret=$((minMeret + enlarge*i))
    printf "\n%s. %s x %s" "$((i+1))" "$aktualMeret" "$aktualMeret"
done
printf "\n"

fixPos_X=12              #ideálisan a 2. karakterre szeretnénk helyezni mögé a kocsit 
startPos=8               #8 az első opció!
maxPos=12                #ennél tovább nem mehet
minPos=$startPos         #elején ez a minimum is
aktualPos=$startPos      #kezetben 8-ra rakjuk, így a startposnál van!

#ezt ez alatt kipróbálni printf-el és beszúrással
echo -en "\033[$startPos;12H"            #Kocsi hátramozgatása, így nem írok bele a szövegbe
read -r -n 1 char                        #ciklust indító kezdő beolvasás
#echo $char                              #csupán teszteléshez ellenőrzés volt
while [[ $char != "" ]]; do 
    #printf "%s /t" "${char[1]}"         #13 sor van 
    if [[ $char = "w" ]]; then
        if [[ $((aktualPos-1)) -ge minPos ]]; then
            echo -en "\033[$aktualPos;11H"      #1 karakterrel előrébb lépés, hogy a törlés elkapja a most beírt karaktert
            echo -en "\033[K"                   #sorvég törlése ami kocsi után van

            aktualPos=$((aktualPos-1))          #pozíció értékének csökkentése, ha még tudunk felfele lépni!           
            echo -en "\033[1A"                  #1 sorral feljebb ugrás
            echo -en "\033[$aktualPos;12H"      #visszalépés a 12-es X koordinátára ugyan abban a sorban
        
        else                    #az az ág, ha nincs hely felfele!
            echo -en "\033[$aktualPos;11H"      #1 karakterrel előrébb lépés, hogy a törlés elkapja a most beírt karaktert
            echo -en "\033[K"                   #sorvég törlése ami kocsi után van
            echo -en "\033[$aktualPos;12H"      #visszalépés a 12-es X koordinátára ugyan abban a sorban
        fi
    fi

    if [[ $char = "s" ]]; then
        if [[ $((aktualPos+1)) -le maxPos ]]; then
            echo -en "\033[$aktualPos;11H"      #1 karakterrel előrébb lépés, hogy a törlés elkapja a most beírt karaktert
            echo -en "\033[K"                   #sorvég törlése ami kocsi után van

            aktualPos=$((aktualPos+1))          #pozíció értékének csökkentése, ha még tudunk felfele lépni!           
            echo -en "\033[1B"                  #1 sorral lejebb ugrás
            echo -en "\033[$aktualPos;12H"      #visszalépés a 12-es X koordinátára ugyan abban a sorban
        
        else                    #az az ág, ha nincs hely lefele!
            echo -en "\033[$aktualPos;11H"      #1 karakterrel előrébb lépés, hogy a törlés elkapja a most beírt karaktert
            echo -en "\033[K"                   #sorvég törlése ami kocsi után van
            echo -en "\033[$aktualPos;12H"      #visszalépés a 12-es X koordinátára ugyan abban a sorban
        fi
    fi

    if [[ $char != "w" ]] && [[ $char != "s" ]]; then
        echo -en "\033[$aktualPos;11H"      #1 karakterrel előrébb lépés, hogy a törlés elkapja a most beírt karaktert
        echo -en "\033[K"                   #sorvég törlése ami kocsi után van
        echo -en "\033[$aktualPos;12H"      #visszalépés a 12-es X koordinátára ugyan abban a sorban
    fi

    read -r -n 1 char
done

echo -e  "clear; \033c\e[3J"         #képernyő letisztítása
echo -en "\033[1A"                   #kocsi feljebb ugratása 1-el 
printf "kijutottam enterrel! \n"
