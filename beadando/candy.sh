#!/bin/bash

#név beolvasása
printf "Add meg a neved! \nneved: " 
read -r username
printf "%s \n" "$username"

#karakter irányításhoz beolvasás
while read -r -n 1 char; do
    if [[ $char = "" ]]; then
        printf "enter -> vége" 
    else
        printf "%s \n" "$char"
    fi
done

# ^[[A felfele
# ^[[B lefele
# ^[[C jobbra
# ^[[D ballra