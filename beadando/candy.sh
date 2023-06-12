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
    printf "%s %d \n" "$midWidth" "$midHeight"

    if [[ $width -gt 20 ]] || [[ $height -gt 3 ]]; then #az az ág ahol van hely kiírni a tájékoztatást
        msg="A terminálnak minimum 34 magasságra 64 szélességre van szüksége"
        
        msg_egy="A terminálnak minimum"   
        msg_ketto=" 34  magasság"
        msg_harom=" 64 szélesség"
        msg_negy=" kell!"          

        startPoz_egy=$((midWidth-(${#msg_egy}/2)))
        startPoz_ketto=$((midWidth-(${#msg_ketto}/2)))
        startPoz_harom=$((midWidth-(${#msg_harom}/2)))
        startPoz_negy=$((midWidth-(${#msg_negy}/2)))

        printf "%s %s %s %s \n" "$startPoz_egy" "$startPoz_ketto" "$startPoz_harom" "$startPoz_negy"
        #echo -en "\033[$((midHeight-3));$((startPoz_egy))H"
        #echo "test behúzás"

        #\033[L;CH  $startPoz_egy
        #ezen a ponton még mindig tiszta a terminál a kezdeti törlés után!
        #nem kell 0,0-ra állítani a kurzort, hisz ott van!
        #echo -en "\033[4;$((szam-3))H"
        #\033[1A down
        #\033[1C forward

        #bemozgatás a magasság közepe előtti 2. sorra, kezdő pozira a sorban
        echo -en "\033[$((midHeight-1));$((startPoz_egy))H"  
        printf "%s\n" "$msg_egy"
    
        echo -en "\033[$((midHeight));$((startPoz_ketto))H" 
        printf "%s\n" "$msg_ketto"
        
        echo -en "\033[$((midHeight+1));$((startPoz_harom))H" 
        printf "%s\n" "$msg_harom"
        
        echo -en "\033[$((midHeight+2));$((startPoz_negy))H" 
        printf "%s\n" "$msg_negy"

    else                                                #az az ág ahol nincs hely kiírni a tájékoztatást
        echo "A játéknak több helyre van szüksége a terminálon!"
    fi

    read -r -n 1 char
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
