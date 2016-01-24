#!/bin/bash

. generated-cells.bash

#set -x

for (( i=0, n="${#cells[@]}" ; i<n ; i++ ))
do
    declare -p "${cells[$i]}"
done