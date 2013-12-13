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
        rpm -qa mysql-server* | grep -qw mysql-server || 
	{ yum install -y mysql-server mysql.$arch;
	  mysqladmin status || /etc/init.d/mysqld restart;
          eval $set_password; 
	}
}

ubunt_installation(){
        export DEBIAN_FRONTEND=noninteractive

	dpkg -l | grep -qw mysql-server ||
        { 
	 apt-get -q -y install mysql-server;
	 mysqladmin status || /etc/init.d/mysqld restart;
         eval $set_password;
	}
}

install_packages() {
        case $package_manager in
                RHEL*   ) rhel_installation     ;;
                Ubuntu* ) ubunt_installation    ;;
        esac
}

ask() { 
	while true
	do
		read -p "Do you want to add more Instance (y/n)?" ans
		case $ans in 
			[yY]|[yY][eE][sS]) 	ans=yes; break ;;
			[nN]|[nN][oO])		ans=no;  exit 0 ;;
					*)	echo "Please Press (y/n)" ;;
		esac
	done
}

setup_new_instance(){

	echo  "MySQL Successfully Installed"
	ask
	total_instance=$( ls -1d /var/lib/mysql* | wc -l )
	(( total_instance++ ))
	i=total_instance
	port=$[ 3306 + $i ]
	location=/var/lib/mysql
	logpath=/var/log/mysql${i}
	[[ -d ${location}${i} ]] && { echo "Already Exists"; exit 1; }
	mkdir ${location}${i}
	mkdir /var/log/mysql${i}
	chown -R mysql. ${location}${i} $logpath
	cnf=/etc/my${i}.cnf
	cp /etc/init.d/mysql /etc/init.d/mysql${i}
	
	cp /etc/my.cnf $cnf
	cd /etc/mysql${i}
	sed -i "s/3306/$port/g" $cnf
	sed -i "s/mysqld.sock/mysqld$i.sock/g" $cnf
	sed -i "s/mysqld.pid/mysqld$i.pid/g" $cnf
	sed -i "s/var\/lib\/mysql/var\/lib\/mysql$i/g" $cnf
	sed -i "s/var\/log\/mysql/var\/log\/mysql$i/g" $cnf
	mysql_install_db --user=mysql --datadir=/var/lib/mysql$i/	

}


Main(){
	install_packages
	setup_new_instance
}

Main
