#!/bin/bash

cat << 'EOF' > /root/JoinAD.sh
#!/bin/bash
### BEGIN INIT INFO
# Provides:          JoinAD
# Required-Start:    $all
# Required-Stop:
# Default-Start:      3 4 5
# Default-Stop:
# Short-Description: JoinAD script
### END INIT INFO
#
# JoinAD   Join AD Script post install
#
# chkconfig: 345 70 30
# description: Post-install script to Join server to AD Domain
# processname: JoinAD

# Source function library.
. /etc/init.d/functions

RETVAL=0
prog="JoinAD"
LOCKFILE=/var/lock/subsys/$prog
OPTION=$1

# Declare variables for script
DOMAIN=ATLANTA.TESTING-LABS.NET

# Exit script if HOSTNAME is not set
if [ "$HOSTNAME" = "localhost" ]; then
    echo "System HOSTNAME is not set, cannot joing domain..exiting !"
    exit 1
else
    echo "System Hostname: $HOSTNAME"
fi

start() {
        echo "Initiating $prog: "
        echo "Checking if already joined to domain..."
        # CentOS option
        #ISJOINED=`adcli testjoin`
        ISJOINED=`realm list | grep -i $DOMAIN`
        RETVAL=$?
        if [ $RETVAL -gt 0 ] ;then
           echo  "Joining Domain $DOMAIN"
           # CentOS option
           #echo $AWSCONNECTORPASS | adcli join --stdin-password -U awsadconnector@ATLANTA.TESTING-LABS.NET  ATLANTA.TESTING-LABS.NET
           echo $AWSCONNECTORPASS | realm join -U awsadconnector@ATLANTA.TESTING-LABS.NET  ATLANTA.TESTING-LABS.NET

           # Ubuntu Option
           #expect -c '
            # spawn bash
            #    sleep 0.3
            #    send -- "realm join -U awsadconnector@ATLANTA.TESTING-LABS.NET  ATLANTA.TESTING-LABS.NET\n"
            #    sleep 15
            #    expect "Password for awsadconnector@ATLANTA.TESTING-LABS.NET:"
            #    send -- “xxxxxx!\n”
            #    expect "#"
            #    send -- "exit\n"
            #    interact
            #    exit
            #'
            # Test again if it havi s joined the domain
            #ISJOINED=`adcli testjoin`
            ISJOINED=`realm list | grep -i $DOMAIN`
            RETVAL=$?
            if [ $RETVAL -eq 0 ]; then
               echo "Joined Domain: $DOMAIN"
               # CentOS option - Fix PAM configuration
               echo "Running Authconfig"
               authconfig --enablesssd --enablesssdauth --enablemkhomedir --update
               if [ $? -ne 0 ]; then
                  echo "Authconfig failed to run sucessfully ..."
                fi
               # Fix SSSD.conf
               echo "Fixing /etc/sssd/sssd.conf"
               # Fix the realm Format
               sed -i 's/#\?\(use_fully_qualified_names =\s*\).*$/\1 False/' /etc/sssd/sssd.conf
               sed -i 's/#\?\(fallback_homedir =\s*\).*$/\1 \/home\/\%u/' /etc/sssd/sssd.conf
               echo "Restarting SSSD service"
               # Restart sssd daemon
               chkconfig sssd on
               service sssd restart
               echo "Sucessfully Joined domain: $DOMAIN"
               echo "Use: realm list - to check status"
            else
                echo "Failed to Join Domain $DOMAIN"
            fi
        else
            echo "Already joined to domain $DOMAIN or "
            echo  "Skipping ..... "
        fi
        echo
        return $RETVAL
}

stop() {
        echo "Doing nothing .... if you want to leave domain"
        echo "Use: realm leave"
        RETVAL=$?
        echo
        return $RETVAL
}

status() {
        echo -n "Checking $prog status: "
        realm list
        echo
        RETVAL=$?
        return $RETVAL
}

case "$OPTION" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    restart)
        stop
        start
        ;;
    *)
        echo "Usage: $prog {start|stop|status|restart}"
        exit 1
        ;;
esac
exit $RETVAL
EOF

chmod +x /root/JoinAD.sh

cat << EOF > /etc/systemd/system/JoinAD.service
[Unit]
Description=Script to Join Active Directory
After=network.target

[Service]
Type=simple
ExecStart=/root/JoinAD.sh start
ExecStop=/root/JoinAD.sh stop
TimeoutStartSec=30

[Install]
WantedBy=default.target
EOF

# Enable ADJoin Service
systemctl daemon-reload
systemctl enable JoinAD
