#!/bin/bash

set -f
filepath=$(mktemp)

getinfo_file() {
        read -p "Enter File name :- " filename
        read -p "Enter Path where you want to search $filename :- " path
}

find_that(){
        find $path -iname *"$filename"* > $filepath
}

getinfo_remote_srv() {
        read -p "Enter Remote Server IP & User: [champu@127.0.0.1] :" server
        read -p "Enter Remote Server Path [/tmp]: " rpath
        [[ -z $rpath ]] && rpath=/tmp/
        [[ -z $server ]] && server=champu@127.0.0.1
        remote_server=${server}:${rpath}
}

confirm() {
        while :
        do
                cat $filepath
                read -p  "Do you want to copy above files on remote server? y/n?" ans
                case "${ans}" in
                        [yY]|[yY][eE][sS]) break    ;;
                            [nN]|[nN][oO]) exit 1   ;;
                                   *) echo error, please ans y/n ;;
                esac
        done

}


fire_scp() {

        cat ${filepath} | xargs echo | xargs -I{} echo scp -r {} $remote_server | sh
}

Main() {

        getinfo_file
        find_that
        getinfo_remote_srv
        confirm
        fire_scp
        [[ -f $filepath ]] && rm -vf $filepath

}

Main
