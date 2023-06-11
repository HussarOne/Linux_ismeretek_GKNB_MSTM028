#!/bin/bash

minMeret_XY=11
enlarge=2
aktualMeret_XY=$minMeret_XY
counter=2

aktualMeret_XY=$((aktualMeret_XY+enlarge*(counter+1)))

printf "%s \n" "$aktualMeret_XY"
