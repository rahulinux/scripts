add_tacacs_login(){
        local ip="${1:?"IP not Specified"}"
        local tacacs_login_file=/path/of/tacacs_login

        if ! grep -q "${ip}"  "${tacacs_login_file}"; then
                cat <<-EOF >> "${tacacs_login_file}"
                add user ${ip} username
                add password ${ip} {password1} {password2}
                EOF
        fi
}

# add ip in tacacs login file is it not exists
add_tacacs_login $ip
