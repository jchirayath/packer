# Update the packates
echo "Updating all packages !"
yum -y update

# Run the virtual-guest tuned profile
#echo "virtual-guest" > /etc/tune-profiles/active-profile
echo "Installing tuned"
yum -y install tuned
service tuned start
chkconfig tuned on
tuned-adm profile virtual-host

# Fix SSHD to allow Password Authentication
echo "Fixing SSHD to allow password authentication"
sed -i 's/#\?\(PasswordAuthentication\s*\).*$/\1 yes/' /etc/ssh/sshd_config

# Fix DHCP client to add DNS server - Required
# Create updated dhcpclient.conf file
echo "adding domain-suffix to dhcpclient.conf"
cat << EOF >> /etc/dhcp/dhclient.conf
timeout 300;
interface "eth0" {
       append domain-search "atlanta.testing-labs.net", "testing-labs.net";
       append domain-name-servers 172.16.1.10;
      }
EOF

# Add domains to Network Manager
nmcli con mod 'System ens192' ipv4.dns-search "atlanta.testing-labs.net testing-labs.net"

# Add AD Group to Sudoers File
echo "Adding LAB Admins to sudoers"
echo "%Domain\ Admins ALL=(ALL)ALL" >> /etc/sudoers
echo "%LabAdmins ALL=(ALL)ALL" >> /etc/sudoers

# Send files to syslog
echo "Setting Syslog"
echo "*.* @@loghost:514" >> /etc/rsyslog.conf

# Install StaltStack Agent
echo "Installing SaltStack Agent"
curl -L https://bootstrap.saltstack.com | sudo sh

# Install aad-login
echo "Installing aaa-login"
yum -y install git
git clone https://github.com/uberguru/azure-ad-ssh-pam.git

# Install AWS CLI
dnf install python3-pip
pip3 install awscli --upgrade --user

# Cleanup SSH keys
rm -f /etc/ssh/*key*
rm -rf ~/.ssh/
