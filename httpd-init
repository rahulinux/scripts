#!/bin/bash
#
# Startup script for the Apache Web Server
#
# chkconfig: - 85 15
# description: Apache is a World Wide Web server.  It is used to serve \
#              HTML files and CGI.
# processname: httpd
# pidfile: /usr/local/apache2/logs/httpd.pid
# config: /usr/local/apache2/conf/httpd.conf

# Source function library.
. /etc/rc.d/init.d/functions

if [ -f /etc/sysconfig/httpd ]; then
        . /etc/sysconfig/httpd
fi

# This will prevent initlog from swallowing up a pass-phrase prompt if
# mod_ssl needs a pass-phrase from the user.
INITLOG_ARGS=""

# Path to the apachectl script, server binary, and short-form for messages.
apachectl=/usr/local/apache2/bin/apachectl
httpd=/usr/local/apache2/bin/httpd
pid=$httpd/logs/httpd.pid
prog=httpd
RETVAL=0


# The semantics of these two functions differ from the way apachectl does
# things -- attempting to start while running is a failure, and shutdown
# when not running is also a failure.  So we just do it the way init scripts
# are expected to behave here.
start() {
        echo -n $"Starting $prog: "
        daemon $httpd $OPTIONS
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && touch /var/lock/subsys/httpd
        return $RETVAL
}
stop() {
        echo -n $"Stopping $prog: "
        killproc $httpd
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && rm -f /var/lock/subsys/httpd $pid
}
reload() {
        echo -n $"Reloading $prog: "
        killproc $httpd -HUP
        RETVAL=$?
        echo
}

# See how we were called.
case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  status)
        status $httpd
        RETVAL=$?
        ;;
  restart)
        stop
        start
        ;;
  condrestart)
        if [ -f $pid ] ; then
                stop
                start
        fi
        ;;
  reload)
        reload
        ;;
  graceful|help|configtest|fullstatus)
        $apachectl $@
        RETVAL=$?
        ;;
  *)
        echo $"Usage: $prog {start|stop|restart|condrestart|reload|status"
		echo $"|fullstatus|graceful|help|configtest}"
        exit 1
esac

exit $RETVAL
