#!/bin/bash

# Write a method which will remove any given character from a String? 

remove_given_char() {
    
    echo ${str//$r_char/}
}

read -p "Enter String :- " str

read -p "Which character you want to remove from [ $str ]:- " r_char

remove_given_char $r_char
