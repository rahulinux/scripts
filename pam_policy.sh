# Take backup of original file
system_auth="/etc/pam.d/system-auth-ac"
[[ -f ${system_auth}-$(date +%F) ]] || cp ${system_auth}{,-$(date +%F)}


sed -i '/^[ ^\t]*password*[ ^\t]*requisite*[ ^\t]*pam_cracklib.so/c\password    requisite     pam_cracklib.so try_first_pass retry=3 type= minlen=8 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1' $system_auth

# if exists then delete line
if grep -qP "^[ ^\t]*auth*[ ^\t]*required*[ ^\t]*pam_tally2.so" $system_auth; then

        sed -i '/^[ ^\t]*auth*[ ^\t]*required*[ ^\t]*pam_tally2.so/d' $system_auth
        sed -i '/^[ ^\t]*auth*[ ^\t]*required*[ ^\t]*pam_env.so/i\auth        required      pam_tally2.so deny=5 unlock_time=180'  $system_auth

else
        sed -i '/^[ ^\t]*auth*[ ^\t]*required*[ ^\t]*pam_env.so/i\auth        required      pam_tally2.so deny=5 unlock_time=180'  $system_auth

fi
