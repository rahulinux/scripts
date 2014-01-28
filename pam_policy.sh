
1.	Enable password complexity

Make changes in the /etc/pam.d/system-auth-ac file as follows.

Take backup of original file:
cp /etc/pam.d/system-auth-ac / etc/pam.d/orig-system-auth-ac-(date)

Find the below line in the file.

password    requisite     pam_cracklib.so

And change as:

password    requisite     pam_cracklib.so try_first_pass retry=3 type= minlen=8 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1

(This will make the password complexity as minimum 8 characters length, minimum 1 digit, 1 uppercase, one lowercase and one special character)

2.	Enable account lockout after failed login attempts

For RHEL 5 add the below lines in /etc/pam.d/system-auth-ac as mentioned below. 


auth        required      pam_tally2.so deny=5 unlock_time=180(Add this line below : auth        required      pam_env.so)

account     required      pam_tally2.so(Add this line below: account     required      pam_unix.so)

For RHEL 6 add the lines in /etc/pam.d/system-auth-ac and /etc/pam.d/password-auth-ac file as mentioned below.

auth        required      pam_tally2.so deny=5 unlock_time=180(Add this line above : auth        required      pam_env.so)

account     required      pam_tally2.so(Add this line above: account     required      pam_unix.so)
