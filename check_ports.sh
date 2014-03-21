#!/bin/bash

# local custom checks for check_mk_agent

# Purpose : Check Ports are Listening or Not 
# Date	  : Wed Mar 19 20:04:23 IST 2014
# Author  : Rahul & Vijayan

# Note	  : this script can check mulitple ports, but don't do this
#	    because it's not shows correct msg in your monitoring tool
#	    so pass only one port 
Timeout=2
IP=127.0.0.1

CheckStatus(){
	local ip=$1
	for port in ${ports[@]}
	do
		if nc -zw${Timeout} ${ip} ${port}
		then
			status=0
			statustxt=OK
		else
			status=2
			statustxt=CRITICAL
			anyerror=1
		fi
		
		echo "$status Port: [ $port ] $statustxt "
	done
	# if any port is down then return critical status
	[[ -z $anyerror ]] && exit 0 || exit 2
}

ShowHelp(){
	cat <<-_EOF
	Usage: $0 [options]

	Options:
	        -p <port>
	        -i <ip> default is 127.0.0.1

	Example:
	        -p 8080,80,443 monitor mulitple ports
		
	_EOF
exit 1
}

(( $# == 0 )) && ShowHelp

while getopts p:i: opt
do
    case $opt in
		p) port=$OPTARG 	 ;;
		i) ipaddr=$OPTARG	 ;;
		*) ShowHelp		 ;;
    esac
done

# set default IP if null
: ${ipaddr:=$IP} 

# after storing arg to var clear all args
shift $(($OPTIND -1))

# if multiple port then store in array
ports=${port//,/ } # do not change this

CheckStatus $ipaddr ${ports[@]}
