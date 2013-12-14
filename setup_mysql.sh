#!/usr/bin/env bash

# Author :- Rahul Patil<http://www.linuxian.com>
# Date   :- Fri Dec 13 17:51:43 IST 2013
# Why ?
        # Setup MySQL Multiple Instance for Testing Scenario
        # Supported Only for CentOS and Ubuntu
# Report issue

# Only root can use this script
[[ $UID == 0 ]] || { echo >&2 "Only root can use this script"; exit 1; }

# set arch
arch="$( [[ "$(uname -m)" =~ 'i686' ]] && echo i386 )" 

# set password for mysql root user
root_pas=test123        
set_password='mysqladmin -u root password $root_pas'

# set OS Ubuntu or CentOS/RHEL
package_manager=$( [[ -x $(command -v yum) ]] && echo "RHEL Based" || echo "Ubuntu Based")


rhel_installation(){
        rpm -qa mysql-server* | grep -qw mysql-server || 
	{ yum install -y mysql-server mysql.$arch;
	  mysqladmin status || /etc/init.d/mysqld restart;
          eval $set_password; 
	  echo  "MySQL Successfully Installed";
	}
}

ubunt_installation(){
        export DEBIAN_FRONTEND=noninteractive

	dpkg -l | grep -qw mysql-server ||
        { 
	 apt-get -q -y install mysql-server;
	 mysqladmin status || /etc/init.d/mysqld restart;
         eval $set_password;
	 echo  "MySQL Successfully Installed";
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

	ask
	total_instance=$( ls -1d /var/lib/mysql* | wc -l )
	(( total_instance++ ))
	i=$total_instance
	port=$[ 3305 + $i ]
	location=/var/lib/mysql${i}
	logpath=/var/log/mysql${i}
	[[ -d ${location} ]] && { echo "Already Exists"; exit 1; }
	mkdir ${location}
	mkdir ${logpath}
	chown -R mysql. ${location} ${logpath}
	cp /etc/init.d/mysql /etc/init.d/mysql${i}
	
        case $package_manager in
                RHEL*)  cnf=/etc/my${i}.cnf
			cp /etc/my.cnf $cnf		;;
                Ubuntu*) cp -R /etc/mysql/ /etc/mysql${i}/
			 cnf=/etc/mysql${i}/my.cnf 	
			 appr=/etc/apparmor.d/usr.sbin.mysqld
			 cp $appr ${appr}${i}
			 appr=${appr}${i}		
			 int_conf=/etc/init/mysql${i}.conf 
			 cp /etc/init/mysql.conf $int_conf ;;
        esac
	
	for config in $cnf $appr $int_conf
	do
		sed -i "s/3306/$port/g" $config
		sed -i "s/mysqld.sock/mysqld$i.sock/g" $config
		sed -i "s/mysqld.pid/mysqld$i.pid/g" $config
		sed -i "s/var\/lib\/mysql/var\/lib\/mysql$i/g" $config
		sed -i "s/var\/log\/mysql/var\/log\/mysql$i/g" $config
		sed -i "s/etc\/mysql/etc\/mysql2/g" $config
	done
	[[ -z $appr ]] || /lib/init/apparmor-profile-load $appr
	mysql_install_db --user=mysql --datadir=/var/lib/mysql$i/	

}


Main(){
	install_packages
	setup_new_instance
}

Main
