#!/bin/bash

declare -A colorTable
declare -A palya
declare -A palya_elemek  
declare -A magassagok
declare -A szelessegek                        

function changeTerminalBGColor {
    ### Szín teszt beállítása
    echo -en "${colorTable[$1]}"
    
    if [[ $4 -eq 1 ]]; then             #csak akkor telítjük a lapot és ugrunk vissza 1,1 re ha a user kérte!
        sorHolder=""
        for((i = 0; i < width; i++)) do
            sorHolder=$sorHolder" "     #festő sor minta
        done

        for((j = 0; j <= height; j++)) do
            echo "$sorHolder"           #sorok nyomtatása amíg van magasság
        done

        echo -en "\033[1;1H"        #terminál kocsi 1,1-es helyre ugratása festés után
    fi
}
function changeTerminalFGColor {
    echo -en "${colorTable[$1]}" ### Szín teszt beállítása
}

#### functionok amik szövegben pozícionálnak:
function DockCursor() {                 #$1 itt a dock_Y! $2 pedig dock_X!
    echo -en "\033[$(($1));$(($2))H"; 
}  

# ezek mind function AimLower() minionjai lesznek
function LowerOneLine() { true;}
function LowerTwoLines() { true;}
function LowerThreeLines() { true;}

#### functionok, mint golyó játszik-e még vagy sem, térképen van-e vagy sem jön
function IsItOnMap() { return 1;}
function IsItAlive() { return 1;}

#### functionok, mint célkereszt mozgatása következik!
function AimLower() {   #újrarajzolni részeket!
    #fontos: lehet, hogy nem lesz szép mert flickerelni fog, ebben az esetben
    #lehet próbálkozni pl: képernyő befagyasztással, vagy teljes újrarajzolással...
   
    #először törölni az eddigit:
    #felső elemek törlése
    echo -en "\033[$((helyez_Y));$((helyez_X))H"
    echo -en "${palya_elemek[szunet]}${palya_elemek[szunet]}${palya_elemek[szunet]}"

    #középső sor, bal rövid rész törlése
    echo -en "\033[$((helyez_Y+1));$((helyez_X))H"
    echo -en "${palya_elemek[szunet]}"

    #középső sor, jobb rövid rész törlése
    echo -en "\033[$((helyez_Y+1));$((helyez_X+4))H"
    echo -en "${palya_elemek[szunet]}"

    #-> nincs +2-es nyomtatás, hiszen az alsó a kövi felsője lesz!
    helyez_Y=$((helyez_Y+2))

    #utána felrajzolni a következőt:
    
    #középső sor, bal rövid rész írása
    echo -en "\033[$((helyez_Y+1));$((helyez_X))H"
    echo -en "${palya_elemek[celrovid]}"

    #középső sor, jobb rövid rész írása
    echo -en "\033[$((helyez_Y+1));$((helyez_X+4))H"
    echo -en "${palya_elemek[celrovid]}"

    #also sor, hosszú 6-as írása
    echo -en "\033[$((helyez_Y+2));$((helyez_X))H"
    echo -en "${palya_elemek[celhosszu]}"
    
    #echo -en "\c$helyez_Y"; 
    #return $hel
}
function AimHigher() { 
    #először törölni az eddigit:

    #törölni az alsó részeket:
    #alsó sor, hosszú törlése
    echo -en "\033[$((helyez_Y+2));$((helyez_X))H"
    echo -en "${palya_elemek[szunet]}${palya_elemek[szunet]}${palya_elemek[szunet]}"

    #középső sor, bal oldal törlése
    echo -en "\033[$((helyez_Y+1));$((helyez_X))H"
    echo -en "${palya_elemek[szunet]}"

    #középső sor, jobb oldal törlése
    echo -en "\033[$((helyez_Y+1));$((helyez_X+4))H"
    echo -en "${palya_elemek[szunet]}"

    #-> nincs offset nélküli nyomtatás, hiszen a felső a kövi alsója lesz!

    #utána felrajzolni a következőt:
    helyez_Y=$((helyez_Y-2))

    #középső sor, bal rövid rész írása
    echo -en "\033[$((helyez_Y+1));$((helyez_X))H"
    echo -en "${palya_elemek[celrovid]}"

    #középső sor, jobb rövid rész írása
    echo -en "\033[$((helyez_Y+1));$((helyez_X+4))H"
    echo -en "${palya_elemek[celrovid]}"

    #felső sor, hosszú 6-as írása
    echo -en "\033[$((helyez_Y));$((helyez_X))H"
    echo -en "${palya_elemek[celhosszu]}"
 
    #echo -en "\c$helyez_Y";
}
function AimRight() { true;}
function AimLeft() { true;}

colorTable=(            #bg = background  fg = foreground
    [bg_black]="\033[40m"        #works 
    [fg_white]="\033[1;97m"      #untested
    [fg_red]="\033[1;91m"        #works
    [fg_blue]="\033[1;94m"       #untested
    [fg_yellow]="\033[1;93m"     #untested
)



echo -e  "clear; \033c\e[3J"        #képernyő letisztítása
echo -en "\033[1A"                  #kocsi feljebb ugratása 1-el 

width=$(tput cols)                  #megadja hány oszlopos a terminálunk
height=$(tput lines)                #megadja hány    soros a terminálunk
                                    #továbbá: echo mentesen adja meg! nem kell törölni!

changeTerminalBGColor "bg_black" "$width" "$height" "1"    #works


minSzel=64  #pálya max szélessége 15 x 15-nél
minMag=40   #lehet hogy csak 32 dunno, majd alaposabban átszámolom

midWidth=$((width/2))               #terminál széelsségének a fele
midHeight=$((height/2))             #terminál magasságának fele

if [[ $width -lt $minSzel ]] || [[ $height -lt $minMag ]]; then
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
            echo -en "\033[$((midHeight+vertIdx[i]));$((startPoz[i]))H"  
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

echo -en "\033[$startPos;$((fix_X))H"                 #Kocsi hátramozgatása, így nem írok bele a szövegbe
read -rsn 1 char                                      #ciklust indító kezdő beolvasás

while [[ $char != "" ]]; do 
   if [[ $char = "w" ]]; then
        if [[ $((aktualPos-1)) -ge minPos ]]; then
            aktualPos=$((aktualPos-1))                #pozíció értékének csökkentése, ha még tudunk felfele lépni!           
            echo -en "\033[$aktualPos;$((fix_X))H"    #visszalépés a 12-es X koordinátára ugyan abban a sorban
        fi
    fi

    if [[ $char = "s" ]]; then
        if [[ $((aktualPos+1)) -le maxPos ]]; then
            aktualPos=$((aktualPos+1))                 #pozíció értékének csökkentése, ha még tudunk felfele lépni!           
            echo -en "\033[$aktualPos;$((fix_X))H"     #visszalépés a 12-es X koordinátára ugyan abban a sorban
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

echo -e "clear; \033c\e[3J"                #képernyő letisztítása
#echo -en "\033[1A"                        #kocsi feljebb ugratása 1-el 

# Háttér visszafeketítése törlés után
changeTerminalBGColor "bg_black" "$width" "$height" "1" 

##Pálya megalkotása és kirajzolása logika
hanyszin=3
szinek=(
    [0]="r"     #red
    [1]="y"     #yellow
    [2]="b"     #blue
)   

## pálya labda színeinek kisorsolása
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
    done
done



palya_elemek=(
    [tetokezd]=" "                    #1db space, 
    [tetofolyt]="▁▁▁▁"                #4db töltés, fedez egy albdát és egy közt
    [tetoveg]="▁▁ "                   #1db space, 2db töltés - a négyzetek után tölt és hagy helyet oldalszegélynek

    [aljakezd]=" "                    #1db space,
    [aljafolyt]="▔▔▔▔"                #4db töltés, fedez egy labdát és egy közt
    [aljaveg]="▔▔ "                   #1db space, 2db töltés - a négyzetek után tölt és hagy helyet oldalszegénynek

    [balol]="▕"
    [jobol]="▏"
                
    [labda]="██"                    #2db teli blokk
    [szunet]="  "                   #2db space

    [celhosszu]="░░░░░░"            #6db részleges blokk
    [celrovid]="░░"                 #2db részleges blokk
) #works

## pálya kirajzolása:
                      #szélességek a test kirajzolásához lookup table
magassagok=(                                #magasságok a test kirajzolásához lookup table
    [7]=17
    [9]=21
    [11]=25
    [13]=29
    [15]=33
)



szelessegek=(
    [7]=32
    [9]=40
    [11]=48
    [13]=56
    [15]=64
)

### magasság matek:
#terminál magasságának fele - táblamagasság fele really..
helyez_Y=$((midHeight-(${magassagok[$kertMeret]}/2)))

### szélesség matek:
#terminál szélességének fele - táblaméret fele really..
helyez_X=$((midWidth-(${szelessegek[$kertMeret]}/2)))

### Középre helyezés pozícionálása
echo -en "\033[$helyez_Y;$((helyez_X))H"    

### tető kirajzolása:
echo -n "${palya_elemek[tetokezd]}"               #mindneképpen kirajzoljuk
for((x=0; x < kertMeret; x++)) do
    echo -n "${palya_elemek[tetofolyt]}"          #kért méretig kitölteni a tetővel, kettesével ugrunk
done
echo "${palya_elemek[tetoveg]}"

helyez_Y=$((helyez_Y+1))                          #sorral lejjebb akarjuk állítani 
echo -en "\033[$((helyez_Y));$((helyez_X))H"      #visszalökés itt történik meg, egy sorral lejjebb

### pályatest kirajzolása:
Y_rowCount=0
for((current_y = 1; current_y < magassagok[$kertMeret]-1 ; current_y++)) do
    echo -n "${palya_elemek[balol]}"   #bal oldal kirajzolása

    for((current_x = 0; current_x < kertMeret; current_x++)) do
        echo -n "${palya_elemek[szunet]}"            #szünet az első négyzetig
        if [[ $((current_y % 2)) -eq 0 ]]; then      #ha a sor páros, akkor labda sor
           
            #szín beállítása pirosra ha "r" a sorsolt érték
            if [[ ${palya[$Y_rowCount,$current_x]} = "r" ]]; then
                changeTerminalFGColor "fg_red" "$width" "$height"
            fi

            #szín beállítása pirosra ha "y" a sorsolt érték
            if [[ ${palya[$Y_rowCount,$current_x]} = "y" ]]; then
                changeTerminalFGColor "fg_yellow" "$width" "$height"
            fi

            #szín beállítása pirosra ha "b" a sorsolt érték
            if [[ ${palya[$Y_rowCount,$current_x]} = "b" ]]; then
                changeTerminalFGColor "fg_blue" "$width" "$height"
            fi

            echo -n "${palya_elemek[labda]}"         #labda nyomtatása adott színnel

            #szín visszaállítása
            changeTerminalFGColor "fg_white" "$width" "$height"

        else
            echo -n "${palya_elemek[szunet]}"        #páratlan esetben ez egy üres sor
        fi
    done

    if [[ $((current_y % 2)) -eq 0 ]]; then
        Y_rowCount=$((Y_rowCount+1))                  #páros ágon vagyunk, tehát itt vannak csak golyók, itt kell nöcelni
    fi

    echo -n "${palya_elemek[szunet]}"                 #szünet a jobb oldali elemig
    echo "${palya_elemek[jobol]}"                     #jobb oldal kirajzolása

    helyez_Y=$((helyez_Y+1))                          #sorral lejjebb akarjuk állítani 
    echo -en "\033[$((helyez_Y));$((helyez_X))H"      #visszalökés itt történik meg, egy sorral lejjebb
done

### padló kirajzolása
echo -n "${palya_elemek[aljakezd]}"
for((x=0; x < kertMeret; x++)) do
    echo -n "${palya_elemek[aljafolyt]}"                 #kért méretig kitölteni a tetővel, kettesével ugrunk
done
echo "${palya_elemek[aljaveg]}"

helyez_Y=$((helyez_Y+1))                                 #sorral lejjebb akarjuk állítani 
echo -en "\033[$((helyez_Y));1H"                         #itt azért 1H mert a sor elejére akarunk jutni 

### célkereszt felrajzolása!
dock_Y=$helyez_Y                                         #reset előtt elmentjük a már kiszámolt értéket tartalmazó Y helyet, ez adja meg a pálya alsó része alatti kurzor pihenp helyet
dock_X=1                                               
helyez_Y=$((midHeight-(${magassagok[$kertMeret]}/2)+1))  #reset helyez_y + modify
helyez_X=$((midWidth-(${szelessegek[$kertMeret]}/2)+1))  #reset helyez_x + modify
Y_null=$((helyez_Y-1))                                   #felelős a tábla felső koordinátájánka megtartásáért középre pozícionálás után
X_null=$((helyez_X))                                     #felelős a tábla bal koordinátájának megtartásáért középre igazítás után
Y_max=$((helyez_Y+1+(($kertMeret-1)*2)))     #helyez_Y-ban benne van, hogy már 1!
X_max=$((helyez_X+1+(($kertMeret-1)*2)))     #helyez_X-ben benne van, hogy már 1!

echo -en "\033[$((helyez_Y));$((helyez_X))H"             #felső alatti sor, szegélytől beljebb a célkereszt hosszú rajzolásához
echo -en "${palya_elemek[celhosszu]}"                     #célkereszt hosszú részének nyomtatása
              
echo -en "\033[$((helyez_Y+1));$((helyez_X))H"           #Y pozíció lejjebb léptetése, szegélytől beljebb a rövid rész rajzolásához
echo -en "${palya_elemek[celrovid]}"                      #célkereszt rövid részének első része

echo -en "\033[$((helyez_Y+1));$((helyez_X+4))H"         #X pozi pseudo betolása, hogy a labda másik oldalán is megrajzoljuk a célkereszt rövid részét 
echo -en "${palya_elemek[celrovid]}"                      #célkereszt rövid részének második része

echo -en "\033[$((helyez_Y+2));$((helyez_X))H"           #Y pozíció lejjebb léptetése, szegélytől beljebb a rövid rész rajzolásához
echo -en "${palya_elemek[celhosszu]}"                     #célkereszt hosszú részének nyomtatása

#cserélni
echo -en "\033[$((dock_Y));$((dock_X))H"                 #előzőleg már az alját elérő Y-t elmentettük, mivel felülírtuk csak innen hívható elő ismét


read -rsn 1 char                                         #ciklust indító kezdő beolvasás
while [[ $char != "" ]]; do 
   if [[ $char = "w" ]]; then
        if [[ $((helyez_Y-2)) -gt $Y_null ]]; then
            AimHigher "$helyez_Y"; DockCursor "$dock_Y" "$dock_X"; fi
            
            #echo -en "\033[$((dock_Y));$((dock_X))H"; 
        #fi
    fi

    if [[ $char = "s" ]]; then
        if [[ $((helyez_Y+2)) -lt $Y_max ]]; then
            AimLower "$helyez_Y"
            echo -en "\033[$((dock_Y));$((dock_X))H"; 
        fi
    fi



    read -rsn 1 char
done

read -rsn 1 char


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