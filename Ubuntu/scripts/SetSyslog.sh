# Send files to syslog
echo "*.* @@loghost:514" >> /etc/rsyslog.conf
service rsyslog restart
