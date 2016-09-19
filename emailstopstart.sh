#!/bin/bash
#
# emailstartstop    Send an email on server startup and shutdown.
#
# chkconfig:    2345 99 01
# description:  Send an email on server startup and shutdown.

EMAIL="{{ email_ids }}"
STARTSUBJ="{{ project }} started on `date`"
STARTBODY="Just letting you know that server "`hostname`" has started on "`date`
STOPSUBJ="{{ project }} shutdown on `date`"
STOPBODY="Just letting you know that server `hostname` has shutdown on `date` {{ inventory_hostname }}"
lockfile=/var/lock/subsys/emailstartstop

# Send email on startup
start() {
    echo -n $"Sending email on startup: "

    echo "${STARTBODY}" | mail -s "${STARTSUBJ}" ${EMAIL}
    RETVAL=$?
    echo
    [ $RETVAL = 0 ] && touch $lockfile
    return 0
}

# Send email on shutdown
stop() {
    echo -n "Sending email on shutdown: "

    echo "${STOPBODY}" | mail -s "${STOPSUBJ}" ${EMAIL}
    RETVAL=$?
    echo
    [ $RETVAL = 0 ] && rm -f $lockfile
    return 0
}

# See how we were called.
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    *)
        echo $"Usage: $prog {start|stop}"
        exit 2
esac
exit ${RETVAL}
