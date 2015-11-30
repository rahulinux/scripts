#!/usr/bin/env python


def apply_rule(n):
   if n%2 == 0:   # if n is even
      return n/2
   elif n%2 == 1: # if n is odd
      return ( n*3 ) + 1
   return "No rule for this number"


def generate_chain(n):
   my_list = []
   while True:
      n = apply_rule(int(n))
      my_list.append(n)
      if my_list[-1] == 1:
         return my_list
         my_list = []
         break

# find logest chain
# Since 1 million calculation hang your lappy let's break into 3 sets
set_1 = max([ generate_chain(l) for l in range(1,333333)],key=len)
set_2 = max([ generate_chain(l) for l in range(333333,666666)],key=len)
set_3 = max([ generate_chain(l) for l in range(666666,1000000)],key=len)

logest_chain = max( [ set_1,set_2,set_3],key=len)

print logest_chain
print "Logest list is of {} integer and length is {}".format(logest_chain[0]/3,len(logest_chain))
