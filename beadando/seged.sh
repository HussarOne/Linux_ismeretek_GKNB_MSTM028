#!/bin/bash

declare -A colorTable

colorTable=(            #bg = background  fg = foreground
    [bg_black]="\033[40m"        #works 
    [fg_white]="\033[1;97m"      #untested
    [fg_red]="\033[1;91m"        #works
    [fg_yellow]="\033[1;93m"     #untested
    [fg_blue]="\033[1;94m"       #untested
    
)

changeTerminalColor() {
    ### Szín teszt beállítása
    echo -en "${colorTable[$1]}"
    sorHolder=""

    for((i = 0; i < width; i++)) do
        sorHolder=$sorHolder" "     #festő sor minta
    done

    for((j = 0; j <= height; j++)) do
        echo "$sorHolder"           #sorok nyomtatása amíg van magasság
    done

    echo -en "\033[1;1H"            #terminál kocsi 1,1-es helyre ugratása festés után
}

#echo -e  "clear; \033c\e[3J"        #képernyő letisztítása
#echo -en "\033[1A"                  #kocsi feljebb ugratása 1-el 

width=$(tput cols)                  #megadja hány oszlopos a terminálunk
height=$(tput lines)                #megadja hány    soros a terminálunk
                                    #továbbá: echo mentesen adja meg! nem kell törölni!

colorHolder="bg_black"
#changeTerminalColor "$colorHolder" "$width" "$height"  #test needed

#colorHolder="fg_red"
changeTerminalColor "fg_blue" "$width" "$height"
#changeTerminalColor "$colorHolder", "$width", "$height"

printf "\nNavigálni a W: felfele és S:lefele gombokkal lehet!"
printf "\nPályaméret választáshoz navigálj a kívánt számra és ENTER!"

read -n 1 char

