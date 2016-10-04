Before jumping to the AWK Programming, you should know some basics programming concepts, that we will cover in this Part.


Concepts 1 - Data Types


# Data Types


In Computer Science a data type or simply type is a classification identifying one of various types of data, such as real, integer or Boolean, that determines the possible values for that type, the operations that can be done on values of that type, the meaning of the data, and the way values of that type can be stored


Examples:
- Numbers (`int`), (e.g., 7, 3.14)
- Booleans (`bool`) (true or false) (1 or 0 )
- Characters (`Char`) ('a', 'b', ... 'z', '1', '2', ... '9', '!', '^', etc)
- Arrays (a list of data (all of the Same Data Type!))


---


Concepts 2 - Variables


# Variables


Variables play a very important role in most programming languages.
A variable allows you to store a value by assigning it to a name, which can be used to refer to the value later.


To assign a variable, use one equals sign ( e.g. `=` )


Examples:


Try in Shell
```
x=1
printf "%d\n" $x
```


in AWK


```
awk 'BEGIN{ x=1; printf "%d\n", x }'
```


signal equal sign is assignment operator. **Warning, while the assignment operator looks like the traditional mathematical equals sign, this is NOT the case. The equals operator is '=='**


Lets take example of useradd script with variable and without variable.


### Without variable


edit `add_user.sh`


```
#!/bin/bash


useradd champu
echo "champu:password" | chpasswd


mkdir /home/champu
cp -a /etc/skel/.bash* /home/champu/
chown -R champu:champu /home/champu/
```


Now think if you want to add one more user using above script, you have to change champu user to everywhere in script, this is where importance of variale comes into the picture..


Now check following script with variable.


### With variable

Note: In latest `useradd` command, it create home directory, but in older version, we need to create home directory. so following example just for understanding the variable. if you face error like directory already exists, then ignore it.

```
#!/bin/bash

user_name=champu
user_pass=password


useradd $user_name
echo "$user_name:$user_pass" | chpasswd

mkdir /home/$user_name
cp -a /etc/skel/.bash* /home/$user_name
chown -R champu:champu /home/$user_name
```


If you know the more commands, then you can make script with less code of lines


```
#!/bin/bash

user_name=champu
user_pass=password


useradd $user_name
echo "$user_name:$user_pass" | chpasswd
mkhomedir_helper $user_name
```


---


Concept 3 Relational/Conditinal Operators


### Exit status


A relational operator checks the relationship between two operands


As system administrator, if you need to understand the relational operators, then you can think like if command fail and successed


Lets run command `ls` and check the exit status using `echo $?`


```
ls
echo $?
```
The output is zero, that mean commmand is successfully ran.


Now lets run unknown command which does not exists


```
aljdfls
echo $?
```


The output will be non-zero.. that means command is failed.


Similarly in programming if any condition return `0` means success and non zero means fail. so you need to check `return` value of the program.


Now lets use the Conditional/Relational operator in shell


```
name="champu"
[[ $name == "champu" ]]
echo $?
```


| Operator| Meaning of Operator| Status |
|:------:|:---------------:|:-----------------------:|
| == | Equal to 5 == 3 | returns 0|
| > | Greater than 5 > 3| returns 0|
|< |Less than 5 < 3 | returns 1|
| != | Not equal to 5 != 3| returns 0|
| >= | Greater than or equal to 5 >= 3| returns 0|
|<= | Less than or equal to 5 <= 3| return 1|
---


Now lets start the AWK.


## AWK


#### History
- The name awk comes from the initials of its designers: Alfred V. Aho, Peter J. Weinberger, and Brian W. Kernighan
- awk was written in 1977 at AT&T Bell Laboratories


### You can use AWK :
- manage small, personal databases
- generate reports
- validate data
- produce indexes, and perform other document preparation tasks


### Terminology
- Awk recognizes the concepts of "file", "record", and "field".
- A file consists of records, which by default are the lines of the file. One line becomes one record.
- Awk operates on one record at a time.
- A record consists of fields, which by default are separated by any number of spaces or tabs.
- Field number 1 is accessed with $1, field 2 with $2, and so forth. $0 refers to the whole record.




### How does AWK Works :


1. Input is read automatically, across multiple files
2. line split into fields (e.g. $1,$2,$3...$NF )
3. if variable is not defined, it will initialized to zero or emtpy string
4. block defined by user executed or defualt block is `{print $0}`


### Special variable


1. FS : Field seperator ( default is whitespace )
2. OFS : Output field seperator
awk -F: '{ OFS="###"; print $1,$2 }' /etc/passwd
3. NR : Number of Records Variable (lines number )
4. NF : Number of Fields in a record


### Initialization and Final Action


AWK has two important patterns which are specified by the keyword called BEGIN and END.


```
BEGIN { Actions}
{ACTION} # Action for everyline in a file
END { Actions }
```


1. Actions specified in the BEGIN section will be executed before starts reading the lines from the input.
2. Between BEGIN and END pattern, will be executed for each record
3. END actions will be performed after completing the reading and processing the lines from the input.


---


#### Get started with Examples


**1. AWK defualt action**
By default Awk prints every line from the file.


```
awk '{ print }' input.txt
```
So it's same as `cat input.txt`


**2. AWK is meant for processing column- oriented**


let's print specific fields using built-in variable


```
awk '{ print $1,$4 }' input.txt
```


AWK by default split line(record) into fields start from $1.. $2... to number of fields.


`NF` built-in variable for number of fields count and `$0` variable for entire line.


**3. Count number of lines in file**


```
awk 'END{ print NR }' input_file
```


It's similar as `wc -l intput_file` but `wc` command also count blank lines, so only count lines you can use:


```
awk 'NF != 0 { count++ } END{ print count }' input_file
```




NR is special variable, ( Number of Records ) ( the line number)


**4. Print specific line from file**


```
awk 'NR==1 { print $0}' /etc/passwd
```


**5. Remove blank lines from files**


```
awk 'NF != 0 { print }' input_file
```


NF is special variable, it means number of fields in line/record




**6. Change Record seperator **


By defualt AWK seperate line/record by new line i.e. "\n"


For example if your data don't have new line, it has pipe seperated lines, then you can change record seperator to pip


RS is special variable for record seperator


```
echo 'line1|line2|line3|line4' > data
```


let print only second line


```
awk 'BEGIN{ RS="|"}{ if (NR==2) print $0 }' data
```


**7. Split data into array**


Let say, you are parsing data which seperated by pipe sign, but inside that another data is seperated by colon :, and you want to extract that.


```
echo "a:b:c|d:e:f|g:h:i" | awk -F'|' '{ split($2,a,":"); print a[2]}'
```


**8. Search for strings**


```
awk '/Linux/{ print $0 }' input
```


Search two strings:


```
awk '/(one|two)/' input_file
```


Similarly you can search and increment the counter to count the words


```
awk '/Linux/{count++}END{ print count}' input
```

**9. Search in specific field**


```
ps -ef | awk '$8 ~ /init/'
```


|Operator|Meaning|
|:-------:|:--------:|
| ~ | Matches |
| !~ | Doesn't matches |




**10. Field Seperator**


AWK uses white space as defualt field seperator, we can simply change it by passing `-F:` argument to awk


for example for passwd file need colon as seperator, then you can simply use:


```
awk -F: '{ print $1 }' /etc/passwd
```


lets find the users who don't have the passwd


```
awk -F: '$2 == ""{ print "No passwd for User:", $1 }' /etc/passwd
```
We can use another way to change field seperator using `FS` variable.


Lets tranform this into awk script


```
#!/usr/bin/awk -f
BEGIN {
     FS=":"
}
{
     if ($2 == ""){
        print "No passwd for user: ", $1;
     }
}
```

Run script 

```
awk -f scripname.awk
```


**11. Change the output seperator**


AWK has built-in variable called `OFS`, which is white space defualt.


```
awk '{ OFS=":::"; print }' input_file
```
