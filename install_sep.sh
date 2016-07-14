#!/bin/bash


## Global vars
sep_url='http://localhost/SymantecEndpointProtection.zip'
pkgs=( wget unzip )
sep_tmp=/tmp/sep/

## RHEL
java_url=http://download.oracle.com/otn-pub/java/jdk/7u71-b14/jdk-7u71-linux-x64.rpm
java_home=/usr/java/jdk1.7.0_71

## DEB
java_home_deb=/usr/lib/jvm/java-7-openjdk-amd64/jre/

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
    printf '%s%*s%s\n' $(tput bold ; tput setaf 1)"${@}" $col "[ Failed  ]"
    tput sgr 0
}

warn() {
    local msg="${@}"
    local char=${#msg}
    local col_size=$(( $(tput cols) - 45))
    local col=$(( col_size - char))
    printf '%s%*s%s\n' $(tput bold ; tput setaf 4)"${@}" $col "[  SKIPP  ]"
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


    info "Installing deps"

    for pkg in ${pkgs[@]}
    do
       info "Installing deps :: $pkg"
       if ! rpm -qa | grep -q $pkg
       then
           yum install -y $pkg
           success "Installed :: $pkg"
       else
           warn "Already Installed :: $pkg"
       fi
    done

    info "Installing Java"
    if type -p java >/dev/null 2>&1
    then
       warn "Java already installed"
    else
       if [[ ! -f /opt/$( basename $java_url ) ]]
       then
           wget -q -O /opt/jdk-7u71-linux-x64.rpm \
               --no-check-certificate --no-cookies \
               --header 'Cookie: oraclelicense=accept-securebackup-cookie' \
               $java_url 
       fi
       rpm -Uvh /opt/$( basename $java_url )
       printf "export JAVA_HOME=/usr/java/jdk1.7.0_71/\nexport PATH=\$PATH:$java_home/bin/\n" \
          > /etc/profile.d/java.sh

    fi
}


sep(){
    info "Downloading sementec antivirus"
    sep_file=SymantecEndpointProtection.zip
    [[ -d $sep_home ]] || mkdir $sep_home
    cd $sep_home
    if [[ ! -f $sep_file ]]
    then
        wget -cnd $sep_url
    fi
    [[ ! -d Configuration ]] && unzip SymantecEndpointProtection.zip
    bash ./install.sh
}

ubuntu(){

    info "Installing deps"

    for pkg in ${pkgs[@]}
    do
       info "Installing deps :: $pkg"
       if ! dpkg -l | grep -q $pkg
       then
           apt-get install -y $pkg
           success "Installed :: $pkg"
       else
           warn "Already Installed :: $pkg"
       fi
    done

    info "Installing Java"
    if type -p java >/dev/null 2>&1
    then
       warn "Java already installed"
    else
       apt-get install openjdk-7-jdk -y 
       printf "export JAVA_HOME=$java_home/\nexport PATH=\$PATH:$java_home_deb/bin\n" \
          > /etc/profile.d/java.sh
       sudo update-alternatives --install /usr/bin/java java $java_home_deb/bin java 1
    
    fi

    sep
}

main(){
   [[ $UID -ne 0 ]] && { echo "You must be root"; exit 1; };
   detect_os
   detect_os_type
   case $_OS in
      redhat) redhat ;;
      ubuntu) ubuntu ;;
           *) fail "unkown OS"; exit 1 ;;
    esac
}

main
