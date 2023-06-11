#!/bin/bash

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
read -r -n 1 char
while [[ $char -ne "" ]]; do          # addig megyünk amíg nem entert kapunk!    
    if [[ ${char[1]} = "w" ]]; 
        then printf "\033[<N>A" 
    fi
    
done

# ^[[A felfele
# ^[[B lefele
# ^[[C jobbra
# ^[[D ballra