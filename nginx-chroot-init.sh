#!/bin/bash
#
## Nginx Chroot init script 
#

INIT_SCRIPT="$(readlink -f $0)"
NGINX_CHROOT=/nginx
NGINX_BIN=/opt/nginx/sbin/nginx
CHROOT_BIN=/usr/sbin/chroot

. /lib/lsb/init-functions


case "$1" in

  start) 
		log_daemon_msg "Starting Web service" "Nginx"
		
		${CHROOT_BIN} ${NGINX_CHROOT} ${NGINX_BIN} &&
		log_end_msg 0 || log_end_msg 1 
	        ;;
  stop)
  		log_daemon_msg "Stopping Web service" "Nginx"
  		
		${CHROOT_BIN} ${NGINX_CHROOT} ${NGINX_BIN} -s stop &&
		log_end_msg 0 || log_end_msg 1
		;;
  status)
		PID=$(pgrep -f  ${NGINX_BIN})
		
		if [[ -z ${PID} ]]
		then
			log_action_msg "Nginx not Running.."
			log_end_msg 1
			exit 1
		else
			echo -n "Nginx Running with PID : ${PID}"
			log_end_msg 0
		fi
		
		N_STAT=$(netstat -tulnp | awk "/$(basename ${NGINX_BIN})/{ print \$4}" )
		
		if [[  -z $N_STAT ]]
		then
			log_action_msg "Nginx not listening..."
			log_end_msg  1
		else
			echo -n "Nginx Listening on: ${N_STAT}"
			log_end_msg 0
		fi
		
		;;
 
 reload)
 		if $INIT_SCRIPT test 2>&1 | grep -q successful
 		then
			${CHROOT_BIN} ${NGINX_CHROOT} ${NGINX_BIN} -s reload
			log_end_msg 0
		else
			log_action_msg "Please test configuration file"
			log_end_msg 1
		fi
		log_action_msg "Nginx with chroot reloaded"
		;;
  test)
		${CHROOT_BIN} ${NGINX_CHROOT} ${NGINX_BIN} -t
		;;
 restart)
 		echo -n "Stoping Nginx...."
		${CHROOT_BIN} ${NGINX_CHROOT} ${NGINX_BIN} -s stop && 
		log_end_msg 0 || log_end_msg 1
		echo -n "Starting...."
		${CHROOT_BIN} ${NGINX_CHROOT} ${NGINX_BIN} && 
		log_end_msg 0 || log_end_msg 1
		;;
      *)
		log_action_msg "Usage: $INIT_SCRIPT {start|stop|restart|reload|status|test}"
        	exit 1
        	;;
esac


exit 0
