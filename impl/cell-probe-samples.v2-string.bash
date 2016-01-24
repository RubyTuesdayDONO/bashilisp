#!/bin/bash -e

. cell-samples.v2-string.bash
. cell-accessors.v2-string.bash

#set -x

for (( i=0, n="${#cells[@]}" ; i<n ; i++ ))
do
    cellname="${cells[$i]}"
    printf 'Cell %04d/%04d: %s -> %s\n' "${i}" "${n}" "${cellname}" "${!cellname}"
    cell-is-pair "${cellname}" && printf '%16s%s\n' '' 'is-pair'
    #cell-read-string | read -d '' string-val
done