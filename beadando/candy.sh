#!/bin/bash

echo -e 'clear; \033c\e[3J'            #képernyő letisztítása
echo -e " "                             #képernyő szándékos teleszemetelése
echo -e 'clear; \033c\e[3J'            #ismételt tisztítás

#név beolvasása
printf "Add meg a neved! \nneved: " 
read -r username
#printf "%s \n" "$username"         #tesztelésre kell csak

#pálya elkészítéshez információk
printf "\nNavigálni a W: felfele és S:lefele gombokkal lehet!"
printf "\nPályaméret választáshoz navigálj a kívánt számra és ENTER!"
printf "\nPályaméret lehetőségek:"
minMeret=11                         #pálya minimum mérete, szimmetrikus
enlarge=2                           #opcióknál ennyivel növeljük a méretet szimmetrikusan
aktualMeret=$minMeret               #ez az aktuális méret amit kiírunk választhatónak
for ((i=0; i < 5; i++)) 
do
    aktualMeret=$((minMeret + enlarge*i))
    printf "\n%s. %s x %s" "$((i+1))" "$aktualMeret" "$aktualMeret"
done
printf "\n"

#karakter irányításhoz beolvasás
#read -r -n 1 char
#while [[ $char -ne "" ]]; do          # addig megyünk amíg nem entert kapunk!    
#    if [[ ${char[1]} = "w" ]]; then 
#        printf "\033[<N>A" 
#    fi
#    
#done

echo -en "\033[1;15H"                    #Kocsi hátramozgatása, így nem írok bele a szövegbe
read -r -n 1 char                        #ciklust indító kezdő beolvasás
#echo $char                              #csupán teszteléshez ellenőrzés volt
while [[ $char != "" ]]; do 
    #printf "%s /t" "${char[1]}"
    if [[ $char = "w" ]]; then
        echo -en "\033[1A"
        echo -en "\033[1;15H"
    fi

    if [[ $char = "s" ]]; then
        echo -en "\033[1B"
        echo -en "\033[1;15f"
    fi

    if [[ $char != "w" ]] && [[ $char != "s" ]]; then
        echo -en "\033[K"
    fi

    read -r -n 1 char
done

#\033[L;CH          kocsi pozicióba mozgatása, Sor; Oszlop koordináták
#\033[L;Cf          ugyan az de más a vége, ezt is kipróbálom
#\033[K             sor végének törlése!
#\033[2J            minden törlése, 0,0 pozira ugratja a kurzort
#echo -e 'clear; \033c\e[3J'        működő képernyő törlése!
# ^[[A felfele
# ^[[B lefele
# ^[[C jobbra
# ^[[D ballra