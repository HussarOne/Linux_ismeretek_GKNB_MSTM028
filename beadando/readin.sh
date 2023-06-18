#!/bin/bash

holder=()
while read -r line; do
    holder+=("$line")
done < test.txt

echo "${holder[@]}"