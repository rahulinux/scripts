#!/bin/bash


info(){

   tput bold
   tput setaf 2 
   echo "${@}"
   tput sgr 0

}

success() {
    local msg="${@}"
    local char=${#msg}
    local col_size=$(( $(tput cols) - 45))
    local col=$(( col_size - char))
    printf '%s%*s%s\n' $(tput bold )"${@}" $col "[ Success ]"
    tput sgr 0
}

fail() {
    local msg="${@}"
    local char=${#msg}
    local col_size=$(( $(tput cols) - 45))
    local col=$(( col_size - char))
    printf '%s%*s%s\n' $(tput bold ) $(tput setaf 1) "${@}" $col "[ failed ]"
    tput sgr 0
}


detect_os(){

    info "Detecting OS..."

    if python -mplatform | grep -qi Ubuntu
    then
        _OS=ubuntu
    elif python -mplatform | grep -Eqi 'centos|fedora|redhat'
    then
        _OS=redhat
    else
        _OS=unknown
       fail "OS detected.... [$_OS]"
       return 1
        
    fi
    success "OS detected.... [$_OS]"
    
}

detect_os_type(){

    info "Detecting OS type..."
    if python -mplatform | grep -qi x86_64
    then
        _OS_TYPE=x86_64
    else
        _OS_TYPE=i386
        fail"Only for 64 bit OS"
        exit 1
    fi

    success "OS Type detected.... [$_OS_TYPE]"
}

redhat(){

    info "Installing Java"
    if type -p java 2>/dev/null
    then
       fail "Java already installed"
    else
       wget -q -O /opt/jdk-7u71-linux-x64.rpm \
           --no-check-certificate --no-cookies \
           --header 'Cookie: oraclelicense=accept-securebackup-cookie' \
           http://download.oracle.com/otn-pub/java/jdk/7u71-b14/jdk-7u71-linux-x64.rpm 
       rpm -Ubht /opt/jdk-7u71-linux-x64.rpm
       printf 'export JAVA_HOME=/usr/java/jdk1.7.0_71/\nexport PATH=$PATH:/usr/java/jdk1.7.0_71/\n' \
          > /etc/profile.d/java.sh
    fi

}

main(){
   
   detect_os
   detect_os_type
   case $_OS in 
      redhat) redhat ;;
      ubuntu) echo ubuntu ;;
           *) fail "unkown OS"; exit 1 ;;
    esac
}

main
