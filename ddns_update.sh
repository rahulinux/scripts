#!/bin/bash

# Purpose : DDNS Update
# Author  : Rahul Patil<http://www.linuxian.com>
# Date    : Fri Jan 17 22:54:38 IST 2014

# configure fqdn in /etc/hosts before using this script


fqdn=test.linuxian.loc
ipaddr=10.20.10.111
key_pass='KAYPASS'
dns_server='aws-monitor-dns.linuxian.loc'
zone='linuxian.loc'
rev_zone='150.21.10.in-addr.arpa'


forward_zone_update() {
    echo "
    server $dns_server
    zone $zone
    key rndc-key $key_pass
    update add ${fqdn}. 8600    IN A ${ipaddr}
    send" | nsupdate
}


reverse_zone_update() {
    echo "
    server $dns_server
    zone $rev_zone
    key rndc-key $key_pass
    update add "${ipaddr##*.}"."${rev_zone}"    8600    IN PTR ${fqdn}.
    send" | nsupdate
}

forward_zone_update
reverse_zone_update
rndc freeze ${zone}
rndc freeze ${rev_zone}
rndc thaw ${zone}
rndc thaw ${rev_zone}
