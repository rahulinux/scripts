# Shell Scripting Basics
---

## Variable

**What is Variable ?**

Everybody have the drawers in the home ? right ? 
So we store different things in that, like  Clothes, Files, books. and we know which drawer have the which things using the lables ? 

So in programming, you store the data and you labled it as the thing you refer. 

 - You have use x + y = 10 in your math class. do you remember that ? yes .. x and y is the variables.
 - Variables are common for every programming/scripting language 
 - Every script/program keep track of stuff, like when you create facebook login you have to feel details like name, age, sex. we put this information into variable
 - Variable just a container for the value and that value can vary.. hence the name variable. 

#### Rules for Variable 
  - They should start with latters or _underscore
  - They should not start with Numbers 
  - Everything should be case sensitive

#### Examples variable assignement 

Now let's assign some variable 

```
name=champu
age=21

echo "my name $name and I'm $age year old"
```
Notice that we use equal sign (`=`) for assing value to variable, and we use dollar sin ( $ ) to get the value of variable. 

### Variable substitution 
The name of a variable is a placeholder for its value, the data it holds. Referencing (retrieving) its value is called variable substitution.

### partial quoting/ weak qouting 
Enclosing a referenced value in double quotes (" ... ") does not interfere with variable substitution. 

```
var="  This is test"
echo "$var"
```
Output
```
This is test
```
With Quoting

```
echo "$var"
```
Output

```
  This is test
```

### What it does ?
  - Quoting a variable preserves whitespace.

### full quoting, strong quoting
Using single quotes (' ... ') causes the variable name to be used literally, and no substitution will take place. 

```
echo '$var'
```

### What it does ?
  - Variable referencing disabled (escaped) by single quotes, which causes the "$" to be interpreted literally.


### How to unset variable 

```
unset var 
```


---

if you are from Programming background, you might thinking that multiple variable can be assign in single line, we can do the same in Shell also using `read` command

*For Example*
```bash
read name age < <( echo Shyam 22)
```

But I would suggest don't use this because it's kill the readablity of your code, but some cases where you need to use this, lat say if you want to run command and save output into mulitple variable then the command will be called once instead of again and again for every variable set.

*For Example*

```
current_hour=$(date +%H)
current_minute=$(date +%M)
echo "Time: $current_hour $current_minute"
```

Instead of above we can simply use

```
read current_hour current_minute < <( date "+%H %M")
echo "Time: $current_hour $current_minute"
```

### Types of Variable 

When shell run that time three types of variable present:


 - **Envrironment variable**: which are passed on to every executed program. we use export command to set this variable, you can view it by using `env` command. 
   - Used to configure other commands or programs.
   - Inherited by child shells.
   - Stored in /etc/profile, /etc/profile.d/*, ~/.bash_profile, ~/.bash_login and ~/.profile scripts.
   - to set env var `export VAR=value`

 - **Local variable/Shell variable**:  which use to enable/disable the shell features or like reserve variable eg.
     - Local to a single shell by default. They are not inherited by child shells.
     - Stored in /etc/bashrc and ~/.bashrc scripts.
     - BASH   – Full file name used to invoke the instance of bash
     - COLUMNS   – Width of terminal when printing selection lists
     - HISTFILE     – Name of the file in which command history is saved
     - PS1 – Appearance of the primary prompt string for bash
 

---
# Command substitution

As of now you know how to assign variable, now we will see how to store command output into variable.

lets set some variable using commands

```
total_memory=$(free -m | awk '/Mem/{ print $2,"MB"}')
cpu_core=$(awk '/processor/{n++}END{print n}' /proc/cpuinfo)
total_users=$(wc -l < /etc/passwd)

echo "This system has $cpu_core cores CPU's and $total_memory Memory"
echo "Total users: $total_sers"
```

The syntax you see $( <COMMANDS> ), it's called Command substitution
it's a shell features of expansion.
it's actually expands to the output of commands.


**Task1 : Create Server report script using above techniques**
