#!/bin/bash

find_ext="*.txt"
find_path="$PWD"

declare -A meta

cd $find_path || exit 1

while read -a data
do
    meta[${data[0]}]+="${data[1]},"

done < <(md5sum $find_ext | sort -k1 )

for f in ${!meta[@]}
do
    if [[ $( echo ${meta[$f]} | awk -F "," '{ print NF}') -gt 2 ]]
    then
        echo "Same files: ${meta[$f]}"
    fi
done
