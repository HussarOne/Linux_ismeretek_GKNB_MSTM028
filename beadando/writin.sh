#!/bin/bash

path=$(pwd)
sourceFile="/7 x 7.txt"
destFile="/valamiszar.txt"


srcFile=$path$sourceFile
dstFile=$path$destFile

if [ ! -e "$dstFile" ]; then
    touch valamiszar.txt
fi

holder=()
while read -r line; do
    holder+=("$line")
done < "$srcFile"

echo "${#holder[@]}"

echo -n > "$dstFile"
for ((i = 0; i < $((${#holder[@]}-1)); i++ )) do
    echo -e "${holder[$i]}" >> "$dstFile"
done
echo -e " ." >> "$dstFile"