#!/bin/bash

# Create and Attach Volume to Instace using IP Address 

export AWS_ACCESS_KEY_ID=XXXX
export AWS_SECRET_ACCESS_KEY=XXXX
export REGION=us-east-1
export AWS_DEFAULT_REGION=$REGION
VPC=vpc-9d0a6cfb

if [[ $# -ne 1 ]]
then 
    echo "Usage: $0 <hostname|IP>"
    exit 1 
fi


get_instance_id(){
    local host=$1
    # returns ZONE STATUS IP INSTANCE_ID DEVICE
    if ! echo $host | grep -qE '\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}\b'
    then 
         host=$(dig +short $host) 
    fi
    raw_data="$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone, State.Name,PrivateIpAddress,InstanceId,BlockDeviceMappings[*].DeviceName]' \
        --output text | grep -A1 "${host}\t")" 
    instance_data="$( echo "${raw_data}" | head -1 )"
    vid=$( echo "${raw_data}" | grep -o 'sd.' | sort | uniq | tail -1 | cut -c 3- | tr "0-9a-z" "1-9a-z_")
    echo "${instance_data}" "/dev/sd${vid}"
    
}

read ZONE STATUS IP INSTANCE_ID DEVICE <<<"$(get_instance_id $1)"

echo "Creating Volume in Zone $ZONE for IP $IP [ID: $INSTANCE_ID]"

volume_id="$(aws ec2 create-volume --size 20 --region $REGION --availability-zone $ZONE --volume-type standard | jq -r .VolumeId)"

echo "Volume has been created with ID:$volume_id"

echo "Waiting for Volume availability" && sleep 30

echo "Attaching to Instance"
aws ec2 attach-volume --volume-id $volume_id  --instance-id $INSTANCE_ID --device $DEVICE
