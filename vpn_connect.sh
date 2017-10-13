#!/bin/bash
kv_vpn() {
	local action=$1 
	if [[ $action == connect ]]
	then
		/Library/Application\ Support/Checkpoint/Endpoint\ Security/Endpoint\ Connect/command_line  connect -s vpn_address_here -u  username -p password
		touch /tmp/kv.vpn
	elif [[ $action == disconnect ]]
	then
		/Library/Application\ Support/Checkpoint/Endpoint\ Security/Endpoint\ Connect/command_line  disconnect 
		rm  /tmp/kv.vpn
	fi
}



ge_vpn() {
    local action=$1
    if [[ $action == connect ]]
    then
	 echo mypass| \
		 sudo openconnect --user=myuser \
		 --authgroup=ACCESS --passwd-on-stdin   \
		 --servercert  -b myserver
	touch /tmp/ge.vpn 
    elif [[ $action == disconnect ]]
    then
       ps -ef | awk '$8 ~ /openconnect/{ print $2 }' | xargs sudo kill
       sudo /sbin/route delete vpn_route
       rm  /tmp/ge.vpn  
    fi
}

am_vpn() {
    local action=$1
    if [[ $action == connect ]]
    then
	 echo mypass | \
		 sudo openconnect --user=myuser  \
		 --passwd-on-stdin   \
		 -b vpn_address_here
	touch /tmp/am.vpn 
    elif [[ $action == disconnect ]]
    then
       ps -ef | awk '$8 ~ /openconnect/{ print $2 }' | xargs sudo kill
       sudo /sbin/route delete vpn_route
       rm  /tmp/am.vpn  
    fi
}


show_usage() {

cat <<_EOF
USAGE : $0 -a <connect|disconnect|list> -s <site>

Ex. $0 -a connect -s kv
Ex. $0 -a disconnect 
You can also use short <c|d|l>
_EOF

}

echo ${#@}
case $2 in 
	c|connect)
	       shift 3
	       case $1 in 
		       kv) kv_vpn connect ;;
		       ge) ge_vpn connect ;;
		       am) am_vpn connect ;;
		       aws) osascript -e "tell application \"Tunnelblick\"" -e "connect \"rahul.patil\"" -e "end tell" 
			    touch /tmp/aws.vpn
			       ;;
	       esac
	       ;;	       
	d|disconnect)
	       current_vpn=$(basename /tmp/*.vpn | cut -d. -f1 )
	       case $current_vpn in 
		       kv) kv_vpn disconnect ;;
		       ge) ge_vpn disconnect ;;
		       am) am_vpn disconnect ;;
		       aws) osascript -e "tell application \"Tunnelblick\"" -e "disconnect \"rahul.patil\"" -e "end tell" 
			    rm /tmp/aws.vpn
			    ;;
	       esac	      
	       ;; 
	l|list) printf "%s\n" kv ge aws ;;
    	     *) show_usage ;;
esac
