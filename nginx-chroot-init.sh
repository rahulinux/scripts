#!/bin/bash
#
## Nginx Chroot init script 
#

INIT_SCRIPT="$(readlink -f $0)"
NGINX_CHROOT=/nginx
NGINX_BIN=/opt/nginx/sbin/nginx
CHROOT_BIN=/usr/sbin/chroot


check_status(){

	if [[ $? -ne 0 ]];
	then 
		echo "Nginx Chroot " $1 " is unsuccessful. Please contact Administrator"
	fi
	
	exit $?
}

case "$1" in

  start) 
		echo "Starting Nginx with Chroot"
		${CHROOT_BIN} ${NGINX_CHROOT} ${NGINX_BIN} 
		check_status
	        ;;
  stop)
		${CHROOT_BIN} ${NGINX_CHROOT} ${NGINX_BIN} -s stop
		check_status
		;;
  status)
		PID=$(pgrep -f  ${NGINX_BIN})
		
		if [[ -z ${PID} ]]
		then
			echo "Nginx not Running.."
			exit 1
		else
			echo "Nginx Running with PID : ${PID}"
		fi
		
		N_STAT=$(netstat -tulnp | grep $(basename ${NGINX_BIN}))
		
		if [[  -z $N_STAT ]]
		then
			echo "Nginx not listening..."
			exit 1
		else
			echo "Nginx Listening on:"
			echo ${N_STAT}
		
		fi
		
		check_status
		;;
 
 reload)
		${CHROOT_BIN} ${NGINX_CHROOT} ${NGINX_BIN} -s reload
		check_status
		echo "Nginx with chroot reloaded"
		;;
  test)
		${CHROOT_BIN} ${NGINX_CHROOT} ${NGINX_BIN} -t
		;;
 restart)
		${CHROOT_BIN} ${NGINX_CHROOT} ${NGINX_BIN} -s stop
		${CHROOT_BIN} ${NGINX_CHROOT} ${NGINX_BIN}
		check_status
		echo "Nginx restarted"
		;;
      *)
		echo "Usage: $INIT_SCRIPT {start|stop|restart|reload|status|test}"
        	exit 1
        	;;
esac


exit 0
