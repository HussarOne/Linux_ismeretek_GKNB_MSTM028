#!/bin/bash

echo -e  "clear; \033c\e[3J"        #képernyő letisztítása
echo -en "\033[1A"                  #kocsi feljebb ugratása 1-el 

width=$(tput cols)                  #megadja hány oszlopos a terminálunk
height=$(tput lines)                #megadja hány    soros a terminálunk
                                    #továbbá: echo mentesen adja meg! nem kell törölni!

minSzel=64  #pálya max szélessége 15 x 15-nél
minMag=40   #lehet hogy csak 32 dunno, majd alaposabban átszámolom

if [[ $width -lt $minSzel ]] || [[ $height -lt $minMag ]]; then
    midWidth=$((width/2))
    midHeight=$((height/2))
    
    if [[ $width -gt 20 ]] && [[ $height -gt 3 ]]; then #az az ág ahol van hely kiírni a tájékoztatást
        msg="A terminálnak minimum $minMag  magasság $minSzel szélesség kell!"

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

fix_X=12                 #ideálisan a 2. karakterre szeretnénk helyezni mögé a kocsit 
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
            
#játéktér kirajzolása méretszerűen, procedúrálisan, középre igazítva!!
#ezután színezése a tereknek, 

##választott játékpálya kimatekozása
aktualPos=$((aktualPos-7))                  #levonunk 7-et, így 1 és 5 közé esünk a választható opcióknál!

found=0                                     #azért 0, mert TRUE-val negálásra nem reagált jól! Így működik!
k=0
while [[ $k -lt 6 ]] && [[ $found -ne 1 ]]  
do
    k=$((k+1))
    if [[ $k -eq $aktualPos ]]; then
        found=1
    fi
done

kertMeret=$((minMeret-2))                   # A legkisebb pályaméret -2 kell, hogy ha az első opció 1-es érzékével növelünk akkor 7 x 7 legyen!
for((i = 1; i < 6; i++))
do
    if [[ $i -lt $k ]] || [[ $i -eq $k ]]; then
        kertMeret=$((kertMeret+2))
    fi
done
echo -en "\033[13;1H"                       #13. sorra ugrás, majd az elejére, innen írjuk ki a választott pályaméretet szövegesen
printf "\nA kert pályaméret: %s x %s \n" "$kertMeret" "$kertMeret"
sleep 2

echo -e  "clear; \033c\e[3J"                #képernyő letisztítása
echo -en "\033[1A"                          #kocsi feljebb ugratása 1-el 
#read -rsn 1 char         


##Pálya megalkotása és kirajzolása logika
declare -A palya

hanyszin=3
szinek=(
    [0]="r"     #red
    [1]="y"     #yellow
    [2]="b"     #blue
)   

for((i = 0; i < kertMeret; i++)) do
    for((j = 0; j < kertMeret; j++)) do
        holder=$((RANDOM % hanyszin))

        h=0
        found_h=0 
        while [[ h -lt hanyszin ]] && [[ found_h -ne 1 ]]
        do
            if [[ $h -eq $holder ]]; then
                palya[$i,$j]=${szinek[h]}
            fi
            h=$((h+1))
        done

        #printf "%s" "${palya[$i,$j]}"
    done
    #printf "\n"
done

declare -A palya_elemek                          #asszociatív array

palya_elemek=(
    [tetokezd]=" "                    #1db space, 
    [tetofolyt]="▁▁▁▁"                #4db töltés, fedez egy albdát és egy közt
    [tetoveg]="▁▁ "                   #1db space, 2db töltés - a négyzetek után tölt és hagy helyet oldalszegélynek

    [aljakezd]=" "                    #1db space,
    [aljafolyt]="▔▔▔▔"                #4db töltés, fedez egy labdát és egy közt
    [aljaveg]="▔▔ "                   #1db space, 2db töltés - a négyzetek után tölt és hagy helyet oldalszegénynek

    [balol]="▕"
    [jobol]="▏"

    #[uressor7kezd]="                              " #30db space
    #[uressordiff2]="        "                       #8db space
                
    [labda]="██"                    #2db teli blokk
    [szunet]="  "                   #2db space

    [celhosszu]="░░░░░░"            #6db részleges blokk
    [celrovid]="░░"                 #2db részleges blokk
) #works

##pálya kirajzolása:

###tető elvégzése:


echo -n "${palya_elemek[tetokezd]}"       #mindneképpen kirajzoljuk
for((x=0; x < kertMeret; x++)) do
    echo -n "${palya_elemek[tetofolyt]}"   #kért méretig kitölteni a tetővel, kettesével ugrunk
done
echo "${palya_elemek[tetoveg]}"

###pályatest kirajzolása:

for((current_y = 1; current_y < kertMeret; current_y++)) do
    echo -n "${palya_elemek[balol]}"   #bal oldal kirajzolása

    for((current_x = 0; current_x < kertMeret; current_x++)) do
        echo -n "${palya_elemek[szunet]}"            #szünet az első négyzetig
        if [[ $((current_y % 2)) -eq 0 ]]; then      #ha a sor páros, akkor labda sor
            echo -n "${palya_elemek[labda]}"         #labda nyomtatása
        else
            echo -n "${palya_elemek[szunet]}"        #páratlan esetben ez egy üres sor
        fi
    done

    echo -n "${palya_elemek[szunet]}"  #szünet a jobb oldali elemig
    echo "${palya_elemek[jobol]}"      #jobb oldal kirajzolása
done


###padló kirajzolása
echo -n "${palya_elemek[aljakezd]}"
for((x=0; x < kertMeret; x++)) do
    echo -n "${palya_elemek[aljafolyt]}"   #kért méretig kitölteni a tetővel, kettesével ugrunk
done
echo "${palya_elemek[aljaveg]}"


#méretek pályaméretek esetén:
#  7 x  7 = 32 széles, 17 magas wo/ írás és pontok és kurzolnav
#  9 x  9 = 40 széles, 21 magas wo/
# 11 x 11 = 48 széles, 25 magas wo/
# 13 x 13 = 56 széles, 29 magas wo/
# 15 x 15 = 64 széles, 33 magas wo/


#pályatervek:
#szükséges karakterek:
# ▁   alsó nyolcad (felülre!)
# ▏    bal nyolcad (bal oldalra)
# ▕   jobb nyolcad (jobb oldalra)
# ▔  felső nyolcad (alulra!)
# █   teli   blokk (belülre, 2x, ez a labda)
# ░  félig   blokk (célzókereszt, négyzet vastagsága 8 környező blokkban)

#
# ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁ 
#▕    ░░░░░░                 7       9      11      13      15  ▏
#▕  ██░░██░░██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▏
#▕    ░░░░░░                                                    ▏   
#▕  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▏
#▕                                                              ▏                                 ▕ 
#▕  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▏
#▕                                                              ▏ 
#▕  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▏
#▕                                                              ▏ 
#▕  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▏
#▕                                                              ▏ 
#▕  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▏
#▕                                                              ▏ 
#▕7 ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▏
#▕                                                              ▏ 
#▕  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▏
#▕                                                              ▏ 
#▕9 ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▏
#▕                                                              ▏ 
#▕  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▏
#▕                                                              ▏ 
#▕11██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▏
#▕                                                              ▏
#▕  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▏
#▕                                                              ▏ 
#▕13██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▏
#▕                                                              ▏ 
#▕  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▏
#▕                                                              ▏ 
#▕15██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ██  ▏
#▕                                                              ▏
# ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔