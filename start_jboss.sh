#!/bin/bash

# Purpose : If we start JBOSS Server and if server receive connections from clients
#           then it's unable to start service.
#           the temparary solution is, block JBOSS Port until it's start successfully.


# Date   :  Mon Apr 28 16:06:14 IST 2014
# Author :  Rahul Patil<http://www.linuxian.com>


JBOSS_PORT=80
JBOSS_IP=192.168.14.91
JBOSS_PATH=/usr/jboss-eap-5.1/jboss-as/bin
Wait_Time=30 # Wait at least 30 seconds after starting JBOSS
Mail_ID='webmaster@avenues.in'
Trusted_Network='192.168.14.0/255.255.254.0'
Iptables=$(command -v iptables)



test "$(whoami)" != 'root' && (echo you are using a non-privileged account; exit 1)


Block_Incomming_Request(){

        # Block JBOSS_PORT
        # Note: Do not need to start iptables services
        #       Because after inserting rules, it's start.

        $Iptables -L -n -v | grep -q ".*DROP*.*dpt:${JBOSS_PORT}" ||
        $Iptables -I INPUT '!' -s ${Trusted_Network} -p tcp --dport $JBOSS_PORT -j DROP
}


Allow_Incomming_Request(){

        # Allow JBOSS_PORT
        # Remove iptables rules that we were added for
        # Blocking JBOSS_PORT

        $Iptables -L -n -v | grep -q ".*DROP*.*dpt:${JBOSS_PORT}" &&
        $Iptables -D INPUT '!' -s ${Trusted_Network} -p tcp --dport $JBOSS_PORT -j DROP
}



Start_Jboss(){

        # Start Jboss service
        clear
        tput bold
        tput setaf 3
        \cd ${JBOSS_PATH}
        echo "RemitAvenues Server Starting Up..."
        nohup ./run.sh -c default -b ${JBOSS_IP} > /usr/jboss-eap-5.1/jboss-as/bin/nohup.out &
        echo "Wait for $Wait_Time Seconds...."
        sleep $Wait_Time
        /bin/mail -s "RemitAvenues Server Start `date` " ${Mail_ID} < /dev/null
        tput sgr 0 # clear all
}

Check_Jboss(){

        # Return 0 if JBOSS accepting request and gives HTTP 200
        if curl -I http://${JBOSS_IP} | grep -q 'HTTP/1.1 200 OK'
        then
            return 0
        fi
        return 1

}

if Check_Jboss
then
        echo "JBOSS Server is already running.."
        exit 1
else
        Block_Incomming_Request
        Start_Jboss
        Allow_Incomming_Request
fi

