#!/bin/bash

#
## Change LED color based on ICINGA status page
#

LED_API_URL="http://CHANGE_THIS/api/CHANGE_THIS/lights/1/state"
ICINGA_HOST=https://icinga2:5665
ICINGA_QUERY="$ICINGA_HOST/v1/objects/services?attrs=display_name&joins=host.address&filter=service.state"
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


check_status() {
  local curl_opts="-s -k -u $ICINGA_USER:$ICINGA_PASSWORD"
  for s in {1..3}
  do
    if [[ "$(curl $curl_opts $ICINGA_QUERY==$s)" != '{"results":[]}' ]] &&
       curl $curl_opts "$ICINGA_QUERY==$s&attrs=acknowledgement" | \
       grep -q '"acknowledgement":0.0'
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
