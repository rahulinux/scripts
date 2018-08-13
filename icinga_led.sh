#!/bin/bash

#
## Change LED color based on ICINGA status page
#

LED_API_URL="http://CHANGE_THIS/api/CHANGE_THIS/lights/1/state"
ICINGA_HOST=https://icinga2:5665
ICINGA_QUERY="$ICINGA_HOST/v1/objects/comments"
ICINGA_USER=USER
ICINGA_PASSWORD=PASSWORD

led_green() {
   curl -X PUT -d '{"bri":150, "hue":25500}' $LED_API_URL
}

led_orange() {
   curl -X PUT -d '{"bri":150, "hue":5146, "sat":254 }' $LED_API_URL
}

led_red() {
   curl -X PUT -d '{"bri":150, "hue":0}' $LED_API_URL
}

led_purple() {
   curl -X PUT -d '{"bri":150, "hue":56100}' $LED_API_URL
}

get_icinga_data() {
  local curl_opts="-s -k -u $ICINGA_USER:$ICINGA_PASSWORD"
  local more_filters=$1
  local filters="service.acknowledgement!=0&&service.acknowledgement_expiry==0&&$more_filters"
  curl $curl_opts -H 'Accept: application/json' \
     -H 'X-HTTP-Method-Override: GET' \
     -X POST $ICINGA_QUERY -d '
     {
     	"joins": ["service.name", "service.acknowledgement", "service.acknowledgement_expiry"],
     	"attrs": ["author", "text"],
     	"filter": "'$filters'",
     	"pretty": true
    }'
}


check_status() {
  for s in {1..3}
  do
    if [[ "$(get_icinga_data "service.state==$s")" != '{"results":[]}' ]]
    then
      echo $s
      return
    fi
  done
  echo 0
}

status=$(check_status)

case $status in
  0) led_green  ;;
  1) led_orange ;;
  2) led_red    ;;
  *) led_purple ;;
esac
