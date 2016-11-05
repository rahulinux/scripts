#!/bin/bash
n=6

# Hieght 
for i in $( seq 1 $n )
do
     
     # Space 1
     for (( a=$i;a<=$n;a++ ))
     do
         printf " "
     done

     # Stars Part1
     for (( b=1;b<=$i;b++))
     do
          printf "*"
     done

     # Stars Part2
     for (( c=1 ;c<$i; c++ ))
     do
         printf "*"
     done
  
     # new line
     echo ""
done
