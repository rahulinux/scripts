#!/bin/bash


## Global vars
sep_url='http://localhost/SymantecEndpointProtection.zip'
pkgs=( wget unzip )
sep_tmp=/tmp/sep/


java_url=http://download.oracle.com/otn-pub/java/jdk/8u91-b14/jdk-8u91-linux-x64.tar.gz
#java_url=http://localhost/jdk-8u91-linux-x64.tar.gz
java_home=/usr/local/java/jdk1.8.0_91/

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



install_java(){

    info "Installing Java"
    if [[ -x $java_home/bin/java ]]
    then
       warn "Java already installed"
    else
       base=$( dirname $java_home)
       [[ -d $base ]] ||  mkdir $base
       cd $base
       wget  \
           --no-check-certificate --no-cookies \
           --header 'Cookie: oraclelicense=accept-securebackup-cookie' \
           $java_url
       if [[ $? -ne 0 ]]
       then
           echo "Unable to download JAVA $java_url"
           exit 1
       fi
       tar -xzf *.tar.gz
       printf "export JAVA_HOME=$java_home/\nexport PATH=\$PATH:$java_home/bin\n" \
          > /etc/profile.d/java.sh

    fi

    update-alternatives --install /usr/bin/java java $java_home/bin/java 1
    cd /tmp/
    if [[ ! -f $java_home/jre/lib/security/local_policy.jar-bkp ]]
    then
       if [[ ! -f UnlimitedJCEPolicyJDK7.zip ]]
       then
          wget \
           --no-cookies \
           --no-check-certificate \
           --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
           -O UnlimitedJCEPolicyJDK7.zip \
           http://download.oracle.com/otn-pub/java/jce/7/UnlimitedJCEPolicyJDK7.zip
        [[ -d UnlimitedJCEPolicy ]] || unzip UnlimitedJCEPolicyJDK7.zip
        [[ -f $java_home/jre/lib/security/local_policy.jar-bkp ]] || cp $java_home/jre/lib/security/local_policy.jar{,-bkp}
        [[ -f $java_home/jre/lib/security/US_export_policy.jar-bkp ]] || cp $java_home/jre/lib/security/US_export_policy.jar{,-bkp}
        /bin/cp -f UnlimitedJCEPolicy/local_policy.jar $java_home/jre/lib/security/local_policy.jar
        /bin/cp -f UnlimitedJCEPolicy/US_export_policy.jar $java_home/jre/lib/security/US_export_policy.jar
       fi
    fi
    chown 0:0 -R $java_home

}

sep(){
    install_java
    info "Downloading sementec antivirus"
    sep_file=SymantecEndpointProtection.zip
    [[ -d $sep_tmp ]] || mkdir $sep_tmp
    cd $sep_tmp
    if [[ ! -f $sep_file ]]
    then
        wget -cnd $sep_url
                if [[ $? -ne 0 ]]
                then
                   echo "Unable to download SymantecEndpointProtection"
                   echo "Please place file in $sep_tmp/ or change link in script"
                   exit 1
                fi
    fi
    [[ ! -d Configuration ]] && unzip SymantecEndpointProtection.zip
    bash  ./install.sh -i
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
    sep
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
