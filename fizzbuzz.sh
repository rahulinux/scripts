#!/bin/bash

for i in {1..5000}
do

    # 86s for 5k
    #msg=''
    #(( i % 3 )) || msg+='Fizz'
    #(( i % 5 )) || msg+='Buzz'
    #case $msg in 
    #   '') echo $i   ;;
    #    *) echo $msg ;;
    #esac

    # 93s for 5k
    #if [[ $(( i % 3)) -eq 0 ]] && [[ $(( i % 5 )) -eq 0 ]]
    #then
    #    echo "FizzBuzz"
    #elif [[ $(( i % 3 )) -eq 0 ]]
    #then
    #    echo "Fizz"
    #elif [[ $(( i % 5 )) -eq 0 ]]
    #then
    #    echo "Buzz"
    #else
    #    echo $i
    #fi

    # 106s for 5k
    x=$(( i % 3 ))
    y=$(( i % 5 ))
    if [[ $x -eq 0 ]] && [[ $y -eq 0 ]]
    then 
        echo "FizzBuzz"
    elif [[ $x -eq 0 ]]
    then
        echo "Fizz"
    elif [[ $y -eq 0 ]]
    then 
        echo "Buzz"
    else
        echo $i
    fi

done
