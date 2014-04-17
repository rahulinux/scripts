#!/bin/bash

# Purpose : Extract Data of last one month  from radius logs


Log_Path="/var/log/radius/"
Last_Month=$( date --date="$(date +%Y-%m-15) -1 month" +%b )
OutPut="/tmp/radius_users_$(date +%F).csv"
temp1=$(mktemp)

cd $Log_Path || exit 1

for log in $(find . -type f -iname "*log*" )
do

        [[ $log =~ '.gz' ]] && CAT=zcat || CAT=cat
        $CAT $log | while read -a line
        do
                        [[ ${line[@]} =~ $Last_Month ]] || break

                        if [[ ${line[@]}  =~ "Login OK" ]]
                        then

                                        Date="${line[@]::5}"
                                        User=${line[9]}
                                        IP=${line[${#line[@]} - 1 ]%\)}
                                        printf "%s,%s,%s\n" "${Date}" $User $IP | tee -a ${OutPut}
                                        echo "$User" >> $temp1
                        fi
        done
done

Total_Uniq_User=$(sort $temp1 | uniq | wc -l)
printf "%s,%s\n" "Total_Uniq_User" $Total_Uniq_User | tee -a ${OutPut}
echo "Report Generated at \"${OutPut}\""
rm ${temp1}
