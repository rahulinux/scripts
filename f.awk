#!/usr/bin/awk -f
BEGIN{

   #for(i=1;i<=5000;i++){
   #
   #   if (i%3 == 0 && i%5 == 0){
   #     
   #      print "FizzBuzz"
   #   
   #   } else if (i%3 == 0) {

   #      print "Fizz"

   #   } else if (i%5 == 0) {

   #     print "Buzz"

   #   } else {
   #   
   #     print i

   #   }

   #}
   for (i=1;i<=5000;i++){
      msg = "";
      if (i%3==0) { msg = msg"Fizz" };
      if (i%5==0) { msg = msg"Buzz" };
      print (length(msg) == 0)? i : msg;
   }

}
