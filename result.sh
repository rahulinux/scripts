#!/bin/bash
## Purpose :: to show printf formating

line="==================================="

header="\n %-10s %10s %10s \n"

format=" %-10s %10s %11.2f\n"

printf "$header" "Name" "Subject" "Marks"

printf "%s\n" "$line"

printf "$format" \
    Sachin English 90\
    Dhone English 70\
    Virat English 80
