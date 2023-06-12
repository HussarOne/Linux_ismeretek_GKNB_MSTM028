#!/bin/bash

echo -e  "clear; \033c\e[3J"        #képernyő letisztítása
echo -en "\033[1A"                  #kocsi feljebb ugratása 1-el 

width=$(tput cols)                  #megadja hány oszlopos a terminálunk
height=$(tput lines)                #megadja hány    soros a terminálunk
                                    #továbbá: echo mentesen adja meg! nem kell törölni!

minSzel=64  #pálya max szélessége 15 x 15-nél
minMag=34   #lehet hogy csak 32 dunno, majd alaposabban átszámolom

if [[ $width -lt $minSzel ]] || [[ $height -lt $minMag ]]; then
    midWidth=$((width/2))
    midHeight=$((height/2))
    
    if [[ $width -gt 20 ]] || [[ $height -gt 3 ]]; then #az az ág ahol van hely kiírni a tájékoztatást
        msg="A terminálnak minimum 34  magasság 64 szélesség kell!"

        separatorok=(21 34 47 53)
        distances=(
            [0]=$((separatorok[0]-0))
            [1]=$((separatorok[1]-separatorok[0]))
            [2]=$((separatorok[2]-separatorok[1]))
            [3]=$((separatorok[3]-separatorok[2]))
        )

        Msges=(
            [0]=${msg:0:distances[0]}
            [1]=${msg:separatorok[0]:distances[1]}
            [2]=${msg:separatorok[1]:distances[2]}
            [3]=${msg:separatorok[2]:distances[3]}
        )
            
        startPoz=(
            [0]=$((midWidth-(${#Msges[0]}/2)))
            [1]=$((midWidth-(${#Msges[1]}/2)))
            [2]=$((midWidth-(${#Msges[2]}/2)))
            [3]=$((midWidth-(${#Msges[3]}/2)))
        )        

        vertIdx=(-1 0 1 2)
        for((i = 0; i < ${#Msges[@]}; i++))
        do
            echo -en "\033[$((midHeight+(${vertIdx[i]})));$((startPoz[i]))H"  
            printf "%s\n" "${Msges[i]}"
        done

    else                                                #az az ág ahol nincs hely kiírni a tájékoztatást
        echo "A játéknak több helyre van szüksége a terminálon!"
    fi

    read -rsn 1 char
    exit 1
fi 

#pályatervek:
#szükséges karakterek:
# ▁   alsó nyolcad (felülre!)
# ▏    bal nyolcad (bal oldalra)
# ▕   jobb nyolcad (jobb oldalra)
# ▔  felső nyolcad (alulra!)
# █   teli   blokk (belülre, 2x, ez a labda)
# ░  félig   blokk (célzókereszt, négyzet vastagsága 8 környező blokkban)

#
#▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁#
#▏    ░░░░░░                 7       9      11      13      15  ▕
#▏  ██░░██░░██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▕
#▏    ░░░░░░                                                    ▕   
#▏  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▕
#▏                                                              ▕                                 ▕ 
#▏  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▕
#▏                                                              ▕ 
#▏  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▕
#▏                                                              ▕ 
#▏  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▕
#▏                                                              ▕ 
#▏  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▕
#▏                                                              ▕ 
#▏7 ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▕
#▏                                                              ▕ 
#▏  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▕
#▏                                                              ▕ 
#▏9 ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▕
#▏                                                              ▕ 
#▏  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▕
#▏                                                              ▕ 
#▏11██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▕
#▏                                                              ▕
#▏  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▕
#▏                                                              ▕ 
#▏13██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▕
#▏                                                              ▕ 
#▏  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▕
#▏                                                              ▕ 
#▏15██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▕
#▏                                                              ▕
#▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔

#név beolvasása
printf "Add meg a neved! \nneved: " 
read -r username

#pálya elkészítéshez információk
printf "\nNavigálni a W: felfele és S:lefele gombokkal lehet!"
printf "\nPályaméret választáshoz navigálj a kívánt számra és ENTER!"

printf "\n\nPályaméret lehetőségek:"
minMeret=7                          #pálya minimum mérete, szimmetrikus
enlarge=2                           #opcióknál ennyivel növeljük a méretet szimmetrikusan
aktualMeret=$minMeret               #ez az aktuális méret amit kiírunk választhatónak
for ((i=0; i < 5; i++)) 
do
    aktualMeret=$((minMeret + enlarge*i))
    printf "\n%s. %s x %s" "$((i+1))" "$aktualMeret" "$aktualMeret"
done
printf "\n"

fix_X=12              #ideálisan a 2. karakterre szeretnénk helyezni mögé a kocsit 
startPos=8               #8 az első opció!
maxPos=12                #ennél tovább nem mehet
minPos=$startPos         #elején ez a minimum is
aktualPos=$startPos      #kezetben 8-ra rakjuk, így a startposnál van!

echo -en "\033[$startPos;$((fix_X))H"            #Kocsi hátramozgatása, így nem írok bele a szövegbe
read -rsn 1 char                         #ciklust indító kezdő beolvasás

while [[ $char != "" ]]; do 
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

echo -e  "clear; \033c\e[3J"         #képernyő letisztítása
echo -en "\033[1A"                   #kocsi feljebb ugratása 1-el 
