# Image cleanup
echo "Running image cleanup Tasks !"
# Stop logging
service rsyslog stop
service auditd stop

# Cleanup packages
apt autoremove
apt clean

# Remove all the tmp files in
#rm -f /etc/*.rpmnew

# Shrink / rm logs
logrotate -f /etc/logrotate.conf
rm -f /var/log/*-???????? /var/log/*.gz
rm -f /var/log/dmesg.old
rm -rf /var/log/anaconda
cat /dev/null > /var/log/audit/audit.log
cat /dev/null > /var/log/wtmp
cat /dev/null > /var/log/lastlog
cat /dev/null > /var/log/grubby

# cleanup networking
#rm -f /etc/udev/rules.d/70*
#sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-e*
#sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-e*

# Cleanup user SSH
rm -f /etc/ssh/*key*
rm -rf ~/.ssh/

# Clean up user history
rm -f ~/.bash_history
unset HISTFILE
