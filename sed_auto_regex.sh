LOGIN_Params(){
cat <<_CONF
PASS_MAX_DAYS   90
_CONF
}

ChecknAdd() {
    local input_string=${1}
    local config_file=${2}
    local grep_search_pattern=$( echo "${input_string}" |\
                                sed -ne 's/\(^[A-Z_]*\)[ ^\t]*\([0-9]*\)/^[ ^\\t]*\1*[ ^\\t]*\2/p' )
    local restruck_sting_handle_backslash=$( echo ${input_string} | sed 's/\(\/\)/\\\//g' )
    local sed_pattern_1=$(  echo "${restruck_sting_handle_backslash}" |\
                            sed -ne 's/\(^[A-Z_]*\)[ ^\t]*\([0-9]*\)/s\/\\(^[ ^\\t]*\1*[ ^\\t]*\\)\\([0-9]*\\)\/\\1 \2\/g/p' )

    [[ -z $config_file ]] && { Warning "Error: Config file not Specified.."; exit 1; };

    if grep -q -P "${grep_search_pattern}" $config_file ; then
         echo "${input_string}" exists
         echo regex: "${grep_search_pattern}"
    else
         echo "Option ${input_string} Updating...."
         sed -i "${sed_pattern_1}" $config_file

    fi

}

LOGIN_Security_check() {
        local TempConf=$(mktemp)
        LOGIN_Params > "${TempConf}"
        while read value
        do
                ChecknAdd "${value}" /etc/login.defs
        done < "${TempConf}"
        rm -f "${TempConf}"
}

LOGIN_Security_check
