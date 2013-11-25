#!/usr/bin/env bash

CurrDate=$(date +%F)
LC_ALL=C
for files in $(find . -maxdepth 1 -type f ! -iname "*.sh");
do
        FileDate=$( date +%F -r "${files}")

        # don't move todays files
        if [[ $CurrDate != ${FileDate} ]]; then
                DirDate=$(date -d "$(date -r ${files} +'%F -1 day')" +%F)
                if [[ ! -d $DirDate ]]; then
                      mkdir $DirDate
                fi

                mv -v $files $DirDate/
        fi

done
