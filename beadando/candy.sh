#!/bin/bash

declare -A colorTable
declare -A palya
declare -A palya_elemek  
declare -A magassagok
declare -A szelessegek                        
declare -A loves_szam
declare -A pontszam_loves
declare TRUE
#declare FALSE
declare CsereElem

CsereElem="X"

TRUE=0
#FALSE=1

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

        echo -en "\033[1;1H"            #terminál kocsi 1,1-es helyre ugratása festés után
    fi
}
function changeTerminalFGColor {
    echo -en "${colorTable[$1]}"        ### Szín teszt beállítása
}


#### functionok amik szövegben pozícionálnak:
function DockCursor() {                 #$1 itt a dock_Y! $2 pedig dock_X!
    echo -en "\033[$(($1));$(($2))H"; 
}  

# functionok melyek a pálya kirajzolást valósítják meg:
function DrawRoof() { 
    ### tető kirajzolása:
    echo -n "${palya_elemek[tetokezd]}"               #mindneképpen kirajzoljuk
    for ((x=0; x < kertMeret; x++)) do
        echo -n "${palya_elemek[tetofolyt]}"          #kért méretig kitölteni a tetővel, kettesével ugrunk
    done
    echo "${palya_elemek[tetoveg]}"

    helyez_Y=$((helyez_Y+1))                          #sorral lejjebb akarjuk állítani 
    echo -en "\033[$((helyez_Y));$((helyez_X))H"      #visszalökés itt történik meg, egy sorral lejjebb
}

function DrawBody() { 
    ### pályatest kirajzolása:
    y_lepegeto=$((outer_Y_start+1))
    Y_rowCount=0
    for ((current_y = 1; current_y < magassagok[$kertMeret]-1 ; current_y++)) do
        echo -n "${palya_elemek[balol]}"   #bal oldal kirajzolása

        for ((current_x = 0; current_x < kertMeret; current_x++)) do
            echo -n "${palya_elemek[szunet]}"            #szünet az első négyzetig
            if [[ $((current_y % 2)) -eq 0 && ${palya[$Y_rowCount,$current_x]} != "$CsereElem" ]]; then      #ha a sor páros, akkor labda sor
           
                #szín beállítása pirosra ha "r" a sorsolt érték
                if [[ ${palya[$Y_rowCount,$current_x]} = "r" ]]; then
                    changeTerminalFGColor "fg_red" "$width" "$height"; fi

                #szín beállítása pirosra ha "y" a sorsolt érték
                if [[ ${palya[$Y_rowCount,$current_x]} = "y" ]]; then
                    changeTerminalFGColor "fg_yellow" "$width" "$height"; fi

                #szín beállítása pirosra ha "b" a sorsolt érték
                if [[ ${palya[$Y_rowCount,$current_x]} = "b" ]]; then
                    changeTerminalFGColor "fg_blue" "$width" "$height"; fi

                echo -n "${palya_elemek[labda]}"                            #labda nyomtatása adott színnel
                changeTerminalFGColor "fg_white" "$width" "$height" "0"     #szín visszaállítása
            else
               echo -n "${palya_elemek[szunet]}"        #páratlan vagy " " esetben ez egy üres sor/üres elem
            fi
        done

        if [[ $((current_y % 2)) -eq 0 ]]; then
            Y_rowCount=$((Y_rowCount+1))                  #páros ágon vagyunk, tehát itt vannak csak golyók, itt kell nöcelni
        fi

        echo -n "${palya_elemek[szunet]}"                 #szünet a jobb oldali elemig
        echo "${palya_elemek[jobol]}"                     #jobb oldal kirajzolása

        y_lepegeto=$((y_lepegeto+1))                          #sorral lejjebb akarjuk állítani 
        echo -en "\033[$((y_lepegeto));$((outer_X_start))H"      #visszalökés itt történik meg, egy sorral lejjebb
    done
}

function DrawFloor() { 
    ### padló kirajzolása
    echo -n "${palya_elemek[aljakezd]}"
    for ((x=0; x < kertMeret; x++)) do
        echo -n "${palya_elemek[aljafolyt]}"                 #kért méretig kitölteni a tetővel, kettesével ugrunk
    done
    echo "${palya_elemek[aljaveg]}"

    helyez_Y=$((helyez_Y+1))                                 #sorral lejjebb akarjuk állítani 
    echo -en "\033[$((helyez_Y));1H"                         #itt azért 1H mert a sor elejére akarunk jutni 
}

function DrawAimCircle() { 
    echo -en "\033[$((helyez_Y));$((helyez_X))H"             #felső alatti sor, szegélytől beljebb a célkereszt hosszú rajzolásához
    echo -en "${palya_elemek[celhosszu]}"                    #célkereszt hosszú részének nyomtatása
              
    echo -en "\033[$((helyez_Y+1));$((helyez_X))H"           #Y pozíció lejjebb léptetése, szegélytől beljebb a rövid rész rajzolásához
    echo -en "${palya_elemek[celrovid]}"                     #célkereszt rövid részének első része

    echo -en "\033[$((helyez_Y+1));$((helyez_X+4))H"         #X pozi pseudo betolása, hogy a labda másik oldalán is megrajzoljuk a célkereszt rövid részét 
    echo -en "${palya_elemek[celrovid]}"                     #célkereszt rövid részének második része

    echo -en "\033[$((helyez_Y+2));$((helyez_X))H"           #Y pozíció lejjebb léptetése, szegélytől beljebb a rövid rész rajzolásához
    echo -en "${palya_elemek[celhosszu]}"                    #célkereszt hosszú részének nyomtatása

    DockCursor "$dock_Y" "$dock_X"                           #előzőleg már az alját elérő Y-t elmentettük, mivel felülírtuk csak innen hívható elő ismét
}

function DrawTurnsLeft() {
    echo -en "\033[K"
    echo -en "\033[2;1H"
    echo -n "Hátralévő körök száma:"
    for ((i=0; i < $1; i++ )) do echo -n " █"; done 
}

function DrawMap() { 
    DrawRoof
    DrawBody
    DrawFloor
    DrawAimCircle
}


#### functionok, mint golyó játszik-e még vagy sem, térképen van-e vagy sem jön
function IsItExisting() {   #$1 = relatív_Y, $2 = relatív_X 
    if [[ ${palya[$1,$2]} != "$CsereElem" ]]; then
        return 0; # létezik
    fi

    return 1; #nem létezik
}
function IsItOnMap() {      #$1 = relatív Y, $2 = relatív_X 
    if [[ ($1 -gt -1 && $1 -lt $kertMeret) && ($2 -gt -1 && $2 -lt $kertMeret) ]]; then
        return 0;     #létezik
    fi

    return 1; #nem létezik
}
function Reassemble() {     #$1 = relatív_Y, $2 = relatív_X
    seged=()
    pointer=0
    upperBound=$((kertMeret-1))

    for ((i=upperBound; i > -1; i--)); do
        if [[ "${palya[$i,$1]}" != "$CsereElem" ]]; then
            seged+=("${palya[$i,$1]}")
            pointer=$((pointer+1))
        fi 
    done 

    for ((i=pointer; i <= upperBound; i++)) do seged+=("$CsereElem"); done

    local counter=0
    for ((i=upperBound; i > -1; i--)); do palya[$i,$1]=${seged[$((upperBound-i))]} ; done
}

#### functionok, melyek a célkereszthez kellenek!
function AimLower() {   #újrarajzolni részeket!
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
}
function AimHigher() { 
    #először törölni az eddigit:
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
}
function AimRight() { 
    #először törölni az eddigit:
    #balról a sorból,a hosszúból 4 törlése -> 2 szünet
    echo -en "\033[$((helyez_Y));$((helyez_X))H"
    echo -en "${palya_elemek[szunet]}${palya_elemek[szunet]}"

    #középső sor, bal oldal törlése
    echo -en "\033[$((helyez_Y+1));$((helyez_X))H"
    echo -en "${palya_elemek[szunet]}"

    #középső sor, jobb oldal törlése
    #nincs mert az a másik oldal balja lesz majd!

    #also sor balról 4 törlése, azaz 2 szünet
    echo -en "\033[$((helyez_Y+2));$((helyez_X))H"
    echo -en "${palya_elemek[szunet]}${palya_elemek[szunet]}"

    #utána felrajzolni a következőt:
    helyez_X=$((helyez_X+4))

    #felső sor tovább nyomtatása 2 kijelöléssel, azaz 4 karakterrel
    echo -en "\033[$((helyez_Y));$((helyez_X+2))H"
    echo -en "${palya_elemek[celrovid]}${palya_elemek[celrovid]}"

    #középső sor, jobb rövid rész írása
    echo -en "\033[$((helyez_Y+1));$((helyez_X+4))H"
    echo -en "${palya_elemek[celrovid]}"

    #also sor, 4 karakter, vagyis 2 celrovid írása
    echo -en "\033[$((helyez_Y+2));$((helyez_X+2))H"
    echo -en "${palya_elemek[celrovid]}${palya_elemek[celrovid]}"
}
function AimLeft() { 
    #először törölni az eddigit:
    #jobbról a sorból,a hosszúból 4 törlése -> 2 szünet
    echo -en "\033[$((helyez_Y));$((helyez_X+2))H"
    echo -en "${palya_elemek[szunet]}${palya_elemek[szunet]}"

    #középső sor, bal oldal törlése
    #nincs mert az a másik oldal jobbja lesz majd!

    #középső sor, jobb oldal törlése
    echo -en "\033[$((helyez_Y+1));$((helyez_X+4))H"
    echo -en "${palya_elemek[szunet]}"

    #also sor jobbról 4 törlése, azaz 2 szünet
    echo -en "\033[$((helyez_Y+2));$((helyez_X+2))H"
    echo -en "${palya_elemek[szunet]}${palya_elemek[szunet]}"

    #utána felrajzolni a következőt:
    helyez_X=$((helyez_X-4))

    #felső sor tovább nyomtatása 2 kijelöléssel, azaz 4 karakterrel
    echo -en "\033[$((helyez_Y));$((helyez_X))H"
    echo -en "${palya_elemek[celrovid]}${palya_elemek[celrovid]}"

    #középső sor, bal rövid rész írása
    echo -en "\033[$((helyez_Y+1));$((helyez_X))H"
    echo -en "${palya_elemek[celrovid]}"

    #also sor, 4 karakter, vagyis 2 celrovid írása
    echo -en "\033[$((helyez_Y+2));$((helyez_X))H"
    echo -en "${palya_elemek[celrovid]}${palya_elemek[celrovid]}"
}

colorTable=(                        #bg = background  fg = foreground
    [bg_black]="\033[40m"        #works 
    [fg_white]="\033[1;97m"      #untested
    [fg_red]="\033[1;91m"        #works
    [fg_blue]="\033[1;94m"       #untested
    [fg_yellow]="\033[1;93m"     #untested
)

path=$(pwd)

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
    #az az ág ahol van hely kiírni a tájékoztatást
    if [[ $width -gt 20 ]] && [[ $height -gt 3 ]]; then 
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
        for ((i = 0; i < ${#Msges[@]}; i++)) do
            echo -en "\033[$((midHeight+vertIdx[i]));$((startPoz[i]))H"  #works
            printf "%s\n" "${Msges[i]}"
        done

    else    #az az ág ahol nincs hely kiírni a tájékoztatást
        echo "A játéknak több helyre van szüksége a terminálon!"
    fi

    read -rsn 1 char

    echo -e  "clear; \033c\e[3J"        #képernyő letisztítása
    echo -en "\033[1A"                  #kocsi feljebb ugratása 1-el 

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
while [[ $k -lt 6 ]] && [[ $found -ne 1 ]]; do
    k=$((k+1))
    if [[ $k -eq $aktualPos ]]; then
        found=1
    fi
done

kertMeret=$((minMeret-2))                  # A legkisebb pályaméret -2 kell, hogy ha az első opció 1-es érzékével növelünk akkor 7 x 7 legyen!
for ((i = 1; i < 6; i++)) do
    if [[ $i -lt $k ]] || [[ $i -eq $k ]]; then
        kertMeret=$((kertMeret+2))

        #ha még nem létezik a file, akkor ezzel létrehozzuk
        filename=$(printf "/%s x %s.txt" "$kertMeret" "$kertMeret")
        file=$path$filename
        if [ ! -e "$file" ]; then
            printf "\n ." >> "$file"
        fi
    fi
done
echo -en "\033[13;1H"                      #13. sorra ugrás, majd az elejére, innen írjuk ki a választott pályaméretet szövegesen
printf "\nA kert pályaméret: %s x %s \n" "$kertMeret" "$kertMeret"
sleep 2

echo -e "clear; \033c\e[3J"                #képernyő letisztítása
#echo -en "\033[1A"                        #kocsi feljebb ugratása 1-el 

# Háttér visszafeketítése törlés után
changeTerminalBGColor "bg_black" "$width" "$height" "1" 

## Pálya megalkotása és kirajzolása logika
hanyszin=3
szinek=(
    [0]="r"     #red
    [1]="y"     #yellow
    [2]="b"     #blue
    [99]=" "    #üres labda
)   

## pálya labda színeinek kisorsolása
for((i = 0; i < kertMeret; i++)) do
    for((j = 0; j < kertMeret; j++)) do
        palya[$i,$j]=${szinek[$((RANDOM % hanyszin))]}
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
                
    [labda]="██"                      #2db teli blokk
    [szunet]="  "                     #2db space

    [celhosszu]="░░░░░░"              #6db részleges blokk
    [celrovid]="░░"                   #2db részleges blokk
) #works

## pálya kirajzolása:
magassagok=(       #magasságok a test kirajzolásához lookup table
    [7]=17
    [9]=21
    [11]=25
    [13]=29
    [15]=33
)

szelessegek=(       #szélességek a test kirajzolásához lookup table
    [7]=32
    [9]=40
    [11]=48
    [13]=56
    [15]=64
)


### magasság matek:
helyez_Y=$((midHeight-(${magassagok[$kertMeret]}/2)))       #terminál magasságának fele-táblamagasság fele really..
outer_Y_start=$helyez_Y

### szélesség matek:
helyez_X=$((midWidth-(${szelessegek[$kertMeret]}/2)))       #terminál szélességének fele-táblaszélesség fele really..
outer_X_start=$helyez_X

### Középre helyezés pozícionálása
echo -en "\033[$((helyez_Y));$((helyez_X))H"    

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
            changeTerminalFGColor "fg_white" "$width" "$height" "0"
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

inner_Y_min=$((helyez_Y))                                #felelős a tábla felső koordinátájánka megtartásáért középre pozícionálás után
inner_X_min=$((helyez_X))                                #felelős a tábla bal koordinátájának megtartásáért középre igazítás után
inner_Y_max=$((helyez_Y+((kertMeret)*2)))                #belső maximuma ameddig elmehetünk
inner_X_max=$((helyez_X+((kertMeret)*4)))                #belső maximuma ameddig elmehetünk

echo -en "\033[$((helyez_Y));$((helyez_X))H"             #felső alatti sor, szegélytől beljebb a célkereszt hosszú rajzolásához
echo -en "${palya_elemek[celhosszu]}"                    #célkereszt hosszú részének nyomtatása
              
echo -en "\033[$((helyez_Y+1));$((helyez_X))H"           #Y pozíció lejjebb léptetése, szegélytől beljebb a rövid rész rajzolásához
echo -en "${palya_elemek[celrovid]}"                     #célkereszt rövid részének első része

echo -en "\033[$((helyez_Y+1));$((helyez_X+4))H"         #X pozi pseudo betolása, hogy a labda másik oldalán is megrajzoljuk a célkereszt rövid részét 
echo -en "${palya_elemek[celrovid]}"                     #célkereszt rövid részének második része

echo -en "\033[$((helyez_Y+2));$((helyez_X))H"           #Y pozíció lejjebb léptetése, szegélytől beljebb a rövid rész rajzolásához
echo -en "${palya_elemek[celhosszu]}"                    #célkereszt hosszú részének nyomtatása

DockCursor "$dock_Y" "$dock_X"                           #előzőleg már az alját elérő Y-t elmentettük, mivel felülírtuk csak innen hívható elő ismét

pontszam_loves=(
    [1]=8
    [2]=20
    [3]=34
    [4]=50
)

loves_szam=(
    [7]=7
    [9]=11
    [11]=15
    [13]=19
    [15]=23
)

loves_counter=${loves_szam[$kertMeret]}                  #Lövések számának beazonosítása pályaméret alapján

kilep=0                                                  #hany entert ütöttek már le sorba

relativ_Y=0     #megmondja, hogy melyik elemre célzunk a kirajzolt térképen ami a pálya memória reprezentációját végezné
relativ_X=0     #megmondja, hogy melyik elemre célzunk a kirajzolt térképen ami a pálya memória reprezentációját végezné

user_pontszam=0

DockCursor "1" "1"                              #works
echo "$username pontszáma: $user_pontszam"   #works
DrawTurnsLeft "$loves_counter"
DockCursor "$dock_Y" "$dock_X"

while [[ loves_counter -ge 0 && kilep -ne 4 ]]; do
    read -rsn 1 char  #ciklust indító kezdő beolvasás
    while [[ $char != "" ]]; do 

        kilep=0
        if [[ $char = "w" ]]; then
            if [[ $((helyez_Y-2)) -ge $inner_Y_min ]]; then
                AimHigher "$helyez_Y"; DockCursor "$dock_Y" "$dock_X"
                relativ_Y=$((relativ_Y-1));                             fi
        fi

        if [[ $char = "s" ]]; then
            if [[ $((helyez_Y+2)) -lt $inner_Y_max ]]; then 
                AimLower "$helyez_Y"; DockCursor "$dock_Y" "$dock_X" 
                relativ_Y=$((relativ_Y+1));                             fi
        fi

        if [[ $char = "a" ]]; then
            if [[ $((helyez_X-4)) -ge $inner_X_min ]]; then 
                AimLeft "$helyez_X"; DockCursor "$dock_Y" "$dock_X" 
                relativ_X=$((relativ_X-1));                             fi
        fi

        if [[ $char = "d" ]]; then
            if [[ $((helyez_X+4)) -lt $inner_X_max ]]; then 
                AimRight "$helyez_X"; DockCursor "$dock_Y" "$dock_X" 
                relativ_X=$((relativ_X+1)) ;                            fi
        fi

        read -rsn 1 char
    done

    kilep=$((kilep+1)) 
    if [[ kilep -eq 4 ]]; then    #ha két entert ütött egymás után akkor kilépés
        break
    fi

    #golyó létezésének ellenőrzése, ha nem létezik, ne történjen semmi se!
    if [[ "$(IsItExisting "$relativ_Y" "$relativ_X")" -eq $TRUE ]]; then    #amire lőttünk az létezik!
        #ha létezik amire lőttünk bejutunk ide, most ellenőrizzük, hogy a 4 szomszédja létezik-e
        #valamint, hogy a térképen vannak-e!
        counter=0       #ez a változó fogja számontartani, hogy hány szomszédot találtunk!

        ##felette, ugyan azon X-en
        if [[ "$(IsItOnMap "$((relativ_Y-1))" "$relativ_X")" -eq $TRUE  && "$(IsItExisting "$((relativ_Y-1))" "$relativ_X")" -eq $TRUE ]]; 
        then   
            if [[ "${palya[$relativ_Y,$relativ_X]}" = "${palya[$((relativ_Y-1)),$relativ_X]}" ]]; then
                palya[$((relativ_Y-1)),$relativ_X]=$CsereElem            #elem kinullázása            
                counter=$((counter+1))
            fi
        fi

        ##alatta, ugyan azon X-en
        if [[ "$(IsItOnMap "$((relativ_Y+1))" "$relativ_X")" -eq $TRUE && "$(IsItExisting "$((relativ_Y+1))" "$relativ_X")" -eq $TRUE ]]; 
        then    
            if [[ "${palya[$relativ_Y,$relativ_X]}" = "${palya[$((relativ_Y+1)),$relativ_X]}" ]]; then
                palya[$((relativ_Y+1)),$relativ_X]=$CsereElem             #elem kinullázása
                counter=$((counter+1))
            fi
        fi

        ##azonos magasság, balra 
        if [[ "$(IsItOnMap "$relativ_Y" "$((relativ_X-1))")" -eq $TRUE && "$(IsItExisting "$relativ_Y" "$((relativ_X-1))")" -eq $TRUE ]]; 
        then   
            if [[ "${palya[$relativ_Y,$relativ_X]}" = "${palya[$((relativ_Y)),$((relativ_X-1))]}" ]]; then
                palya[$relativ_Y,$((relativ_X-1))]=$CsereElem            #elem kinullázása
                counter=$((counter+1))
            fi
        fi

        ##azonos magasság, jobbra
        if [[ "$(IsItOnMap "$relativ_Y" "$((relativ_X+1))")" -eq $TRUE && "$(IsItExisting "$relativ_Y" "$((relativ_X+1))")" -eq $TRUE ]]; 
        then    
            if [[ "${palya[$relativ_Y,$relativ_X]}" = "${palya[$relativ_Y,$((relativ_X+1))]}" ]]; then
                palya[$relativ_Y,$((relativ_X+1))]=$CsereElem            #elem kinullázása
                counter=$((counter+1))
            fi
        fi

        if [[ counter -gt 0 ]]; then
            palya[$relativ_Y,$relativ_X]=$CsereElem                                #ha volt találat akkor a középső is megsemmisül
            user_pontszam=$((user_pontszam+${pontszam_loves[$counter]}))    #hozzáadjuk a pontszámot
        fi
    
        ## leesés logika:
        if [[ "$(IsItOnMap "0" "$relativ_X")" -eq $TRUE ]];       then
            Reassemble "$relativ_X";                 fi
    
        if [[ "$(IsItOnMap "0" "$((relativ_X+1))")" -eq $TRUE ]]; then
            Reassemble "$((relativ_X+1))";           fi

        if [[ "$(IsItOnMap "0" "$((relativ_X-1))")" -eq $TRUE ]]; then
            Reassemble "$((relativ_X-1))";           fi

        ### redraw rész:
        DockCursor "$((outer_Y_start+1))" "$((outer_X_start))"
        DrawBody                                    #részben works, " " elágazás még nincs tesztelve!
        DrawAimCircle "$helyez_Y" "$helyez_X"       #works #célkereszt újrarajzolása

        loves_counter=$((loves_counter-1))          #lépésszám csökkentése

        DockCursor "1" "1"                           #works
        echo "$username pontszáma: $user_pontszam"   #works
        DrawTurnsLeft "$loves_counter"

        DockCursor "$dock_Y" "$dock_X"              #kurzol visszadokkolása
    fi
done

sleep 2

echo -e "clear; \033c\e[3J"                 #képernyő letisztítása
changeTerminalBGColor "bg_black" "$width" "$height" "1" 
changeTerminalFGColor "fg_white" "$width" "$height" 
echo -en "\033[1A"                          #kocsi feljebb ugratása 1-el

#eredménytábla kiírása:
## adott eredménytábla beolvasása, ugyan azon a táblán játszóttakéval vetjük össze
nameHolder=()
scoreHolder=()

nameHolder+=("$username")
scoreHolder+=("$user_pontszam")

while IFS=";" read -r col1 col2; do
    nameHolder+=("$col1")
    scoreHolder+=("$col2")
done < "$file"

kivantHossz=$((${#scoreHolder[@]}-1))

for ((i = 0; i < kivantHossz; i++)) do
    for ((j = i; j < kivantHossz; j++)) do
        if [ ${scoreHolder[$i]} -lt ${scoreHolder[$j]} ]; then
            score_temp=${scoreHolder[$i]}
            scoreHolder[i]=${scoreHolder[$j]}  
            scoreHolder[j]=$score_temp

            name_temp=${nameHolder[$i]}
            nameHolder[i]=${nameHolder[$j]}
            nameHolder[j]=$name_temp
        fi
    done
done

#25 player, + eredmények kiírása fejléc, + elválasztó vonal
final_Y=$((midHeight-((25+2)/2)-2))

tilte="Rangsor"
echo -en "\033[$((final_Y));$((midWidth - ${#tilte}/2))H" 
printf "%s\n" "rangsor"

final_Y=$((final_Y+1))
final_X=$((midWidth -((20+8+2+4)/2))) #20 balra zárás, 8 tabuláro, 2 szóköz, 4 jobbra zárás 
echo -en "\033[$((final_Y));$((final_X))H" 

echo -en "----------------------------------" #34db
final_Y=$((final_Y+1))
echo -en "\033[$((final_Y));$((final_X))H" 

#Top 25 player, első 25 karaktere! "${palya[$relativ_Y,$relativ_X]}"
for ((i = 0; i < 25 && i < kivantHossz ; i++)) do
    printf "%-25s \t %4.4s\n" "${nameHolder[$i]:0:20}" "${scoreHolder[$i]}"
    echo -en "\033[$((final_Y+i+1));$((final_X))H" 
done

# file felülírása és újra kiírása
printf "%s;%s\n" "${nameHolder[0]}" "${scoreHolder[0]}" >| "$file"
for (( i = 1; i < kivantHossz; i++ )) do
    printf "%s;%s\n" "${nameHolder[$i]}" "${scoreHolder[$i]}" >> "$file"
done
echo " ." >> "$file"
echo "eredmények mentve"
sleep 15
echo -e "clear; \033c\e[3J"                 #képernyő letisztítása
echo -en "\033[1A"                  #kocsi feljebb ugratása 1-el 
read -rsn 1 char