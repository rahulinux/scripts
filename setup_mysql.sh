#!/usr/bin/env bash

# Author :- Rahul Patil<http://www.linuxian.com>
# Date   :- Fri Dec 13 17:51:43 IST 2013
# Why ?
        # Setup MySQL Multiple Instance for Testing Scenario
        # Supported Only for CentOS and Ubuntu
# Report issue

# Only root can use this script
[[ $UID == 0 ]] || { echo >&2 "Only root can use this script" ; exit 1; }

arch="$( [[ "$(uname -m)" =~ 'i686' ]] && echo i386 )" # set arch
root_pas=test123        # set password for mysql root user
set_password='mysqladmin -u root password $root_pas'
# set OS Ubuntu or CentOS/RHEL
package_manager=$( [[ -x $(command -v yum) ]] && echo "RHEL Based" || echo "Ubuntu Based")


rhel_installation(){
	[[ -x $(command -v mysqld)]]
        yum install -y mysql-server mysql.$arch
        mysqladmin status || /etc/init.d/mysqld restart
        eval $set_password
}

ubunt_installation(){
        export DEBIAN_FRONTEND=noninteractive
        apt-get -q -y install mysql-server
        mysqladmin status || /etc/init.d/mysqld restart
        eval $set_password
}

install_packages() {
        case $package_manager in
                RHEL*   ) rhel_installation     ;;
                Ubuntu* ) ubunt_installation    ;;
        esac
}


setup_new_instance(){

	echo  "MySQL Successfully Installed"
	while true
	do
		read -p "Do you want to add more Instance (y/n)?" ans
		case $ans in 
			[yY]|[yY][eE][sS]) 	ans=yes; break ;;
			[nN]|[nN][oO])		ans=no; break ;;
					*)	echo "Please Press (y/n)" ;;
		esac
	done
	
	echo $ans

}


Main(){
	install_packages
	setup_new_instance
}

Main
