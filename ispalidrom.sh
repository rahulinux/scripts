#!/bin/bash

# Write code to check a String is palindrome or not?
# explanation: Palindrome are those String whose reverse is equal to original

ispalidrom() {
    local str=$1
    
    # not following trick can be done using `rev` command
    # but since this programming practice, so try to avoid externel tools
    # as possible 

    revstr=$( for (( i=${#str}; i>0; i-- )); 
              do printf $( expr substr $str $i 1 ); 
              done )

    [[ $str == $revstr ]] && return 0 || return 1
}

read -p "Enter Number :- " num

if ispalidrom $num;
then
    echo "$num is palidrom number"
else
    echo "$num is not palidrom number"
fi


