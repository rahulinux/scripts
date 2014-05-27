#!/bin/bash
#
## Nginx Chroot init script 
#

INIT_SCRIPT="$(readlink -f $0)"
NGINX_CHROOT=/nginx
NGINX_BIN=/opt/nginx/sbin/nginx
CHROOT_BIN=/usr/sbin/chroot

. /lib/lsb/init-functions

check_status(){

	if [[ $? -ne 0 ]];
	then 
		echo "Nginx Chroot " $1 " is unsuccessful. Please contact Administrator"
	fi
	
	exit $?
}

case "$1" in

  start) 
		log_daemon_msg "Starting Web service" "Nginx"
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
			log_action_msg "Nginx not Running.."
			log_end_msg 1
		else
			echo "Nginx Running with PID : ${PID}"
			log_end_msg 0
		fi
		
		N_STAT=$(netstat -tulnp | awk "/$(basename ${NGINX_BIN})/{ print \$4}" )
		
		if [[  -z $N_STAT ]]
		then
			log_action_msg "Nginx not listening..."
			log_end_msg  1
		else
			echo "Nginx Listening on: ${N_STAT}"
			log_end_msg 0
		fi
		
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
 		echo "Stoping Nginx...."
		${CHROOT_BIN} ${NGINX_CHROOT} ${NGINX_BIN} -s stop && log_end_msg 0 || log_end_msg 1
		echo "Starting...."
		${CHROOT_BIN} ${NGINX_CHROOT} ${NGINX_BIN} &&  log_end_msg 0 || log_end_msg 1
		;;
      *)
		log_action_msg "Usage: $INIT_SCRIPT {start|stop|restart|reload|status|test}"
        	exit 1
        	;;
esac


exit 0
