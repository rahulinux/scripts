Code Review

Please note that Code Review is not pin-point, it's only for improving your code 

# KISS Principle <https://en.wikipedia.org/wiki/KISS_principle>

@Sandip/Vishal 
You have both used while loop with increment variable counter which will degrade the server performance.
As mentioned in question need to go 1..100, so you can use bash exapasion feature i.e {1..100} which will create 1 to 100
range number, which we can iterate. 

# Avoid Single bracket [

Let me show you one simple demo, how single bracket [ get failed 

Try in your Shell following code

```
n=""
[ $n -ge 10 ]
```

Output will be

```
-bash: [: -ge: unary operator expected
```

Now try the same with double bracket [[, it will handle the empty variable also. 

# Some little more improvement 
for maths, calculation in doulbe parenthesis (( )), no need to use $i, you can use simply i without doller sign 
incrementing integer variable,  you have used i=$(( $i + 1 )), instead you can use (( i++ )) or let i++ which does the same things

# Solution 1# Simple Script

Now comming to the Simple Code solution for this problem

```
#!/bin/bash

for i in {1..100}
do 
   if [[ $(( i % 3)) -eq 0 ]] && [[ $(( i % 5 )) -eq 0 ]]
   then
       echo "FizzBuzz"
   elif [[ $(( i % 3 )) -eq 0 ]]
   then
       echo "Fizz"
   elif [[ $(( i % 5 )) -eq 0 ]]
   then
       echo "Buzz"
   else
       echo $i
   fi

done
```

# Solution 2# Improved Script

Lets improve something, that we are checking $(( i % 3 )) each time, this we can decrase to only once check at the top

```
for i in {1..100}
do
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
```

# Solution 3# More Improved Script

But somehow it's not improving the performance 

Now lets try to compress the code using some logics

This is smallest and fast bash script.. 

```
for ((i=1;i<=100;i++))
do
    msg=''
    (( i % 3 )) || msg+='Fizz'
    (( i % 5 )) || msg+='Buzz'
    case $msg in 
       '') echo $i   ;;
        *) echo $msg ;;
    esac
done 
```

In AWK 

```
#!/usr/bin/awk -f
BEGIN{
   for (i=1;i<=5000;i++){
      msg = "";
      if (i%3==0) { msg = msg"Fizz" };
      if (i%5==0) { msg = msg"Buzz" };
      print (length(msg) == 0)? i : msg;
   }
}
```


Performance Test with 5K input Numbers

Solution which uses the While Loop
Solution Whileloop# :: Min( real 0m0.226s ) Max( real    0m0.303s )

Solution 1# Min( real 0m0.191s ) Max( real 0m0.283s )
Solution 2# Min( real 0m0.191s ) Max( real 0m0.253s )
Solution 3# Min( real 0m0.185s ) Max( real 0m0.265s )

AWK Performance will always be High because its faster than bash

Solution 4# Min( real 0m0.013s ) Max( real 0m0.014s )

