#!/bin/bash

# Root User Config
ROOT_PW='Password123!'
ROOT_SSH=''

# LabAdmin User Config
MY_PW='Password123!'
MY_SSH=''

# Root Actual Configuration
mkdir -p /root/.ssh/
echo $ROOT_SSH >> /root/.ssh/authorized_keys
echo root:$ROOT_PW | /usr/sbin/chpasswd

# Actual USER Configuration
mkdir -p /home/labadmin/.ssh
echo $MY_SSH >> /home/labadmin/.ssh/authorized_keys
chown labadmin:labadmin /home/labadmin/.ssh/authorized_keys
chown labadmin:labadmin /home/labadmin/.ssh
echo labadmin:$MY_PW | /usr/sbin/chpasswd

# OpenSSH Config
#mkdir /etc/ssh/old_keys
#mv /etc/ssh/ssh_host_* /etc/ssh/old_keys
#dpkg-reconfigure openssh-server
#sed -i 's/*PermitRootLogin*/PermitRootLogin\ without-password/g' /etc/ssh/sshd_config
