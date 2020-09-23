# Join the Domain (MANUALLY)
#echo awsConnector123! | adcli join -U awsadconnector@ATLANTA.TESTING-LABS.NET  ATLANTA.TESTING-LABS.NET

# Fix the krb5.conf file
sed -i 's#EXAMPLE.COM#ATLANTA.TESTING-LABS.NET#g' /etc/krb5.conf
sed -i 's#kerberos.example.com#adminatlad02.atlanta.testing-labs.net#g' /etc/krb5.conf
sed -i 's#example.com#atlanta.testing-labs.net#g' /etc/krb5.conf

# Add ssss to /etc/nsswitch.conf
authconfig --enablesssd --enablesssdauth --enablemkhomedir --update

# Create sssd.conf file
cat << EOF >> /etc/sssd/sssd.conf
[sssd]
services = nss, pam, ssh, autofs
config_file_version = 2
domains = atlanta.testing-labs.net
#debug_level = 9

[domain/ATLANTA.TESTING-LABS.NET]
id_provider = ad
#auth_provider = ad
#chpass_provider = ad
#access_provider = ad
ad_server = adminatlad02.atlanta.testing-labs.net
override_homedir = /home/%u
default_shell = /bin/bash
#ad_gpo_access_control = enforcing
#debug_level = 9

[nss]
#debug_level = 9

[pam]
#debug_level = 9
EOF

# Change permissions for sssd.conf file
chown root:root /etc/sssd/sssd.conf
chmod 600 /etc/sssd/sssd.conf

# Restart sssd daemon
service sssd start
chkconfig sssd on

# Add AD Group to Sudoers File
echo "%AWS\ Admins ALL=(ALL)ALL" >> /etc/sudoers
