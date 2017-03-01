#!/bin/bash

echo "boot db"

export DEBIAN_FRONTEND=noninteractive

send2loggly(){
  if [ -f /root/loggly_token ]; then
    cat <<EOT >> /etc/rsyslog.d/21-prepare.conf
$template msg,"<%PRI%>%timegenerated% %HOSTNAME% %syslogtag% %msg%"

# File access
$InputFileName /tmp/firstboot.log
$InputFileTag prepare.firstboot:
$InputFileStateFile stat-firstboot-Monitor
$InputFileSeverity info
$InputFileFacility local7
$InputFilePollInterval 1
$InputFilePersistStateInterval 1
$InputRunFileMonitor
# File access
$InputFileName /root/startapp.log
$InputFileTag prepare.startapp:
$InputFileStateFile stat-startapp-Monitor
$InputFileSeverity info
$InputFileFacility local7
$InputFilePollInterval 1
$InputFilePersistStateInterval 1
$InputRunFileMonitor

if $syslogtag contains 'prepare.' and $syslogfacility-text == 'local7' then @@LOGTRUST-RELAY:PORT;msg
:syslogtag, contains, "prepare." ~
EOT
    sudo sed -i '/ForwardToSyslog/c\ForwardToSyslog=Yes' /etc/systemd/journald.conf
    /etc/init.d/rsyslog restart
    if [ ! -f configure-linux.sh ]; then
        curl -O https://www.loggly.com/install/configure-linux.sh
    fi
    sudo bash configure-linux.sh -a nicosmaris -t $(cat /root/loggly_token) -u nicos -p $(cat /root/loggly_password)
  fi
}
ports(){
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow ssh
  ufw allow 9042/tcp # cassandra
  sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
  ufw --force enable
}

deploy(){
  apt-get -y install build-essential python-dev git 
  wget --no-check-certificate https://bootstrap.pypa.io/ez_setup.py -O - | python - 'setuptools==26.1.1'
  wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py -O - | python - 'pip==8.1.2'

  ifconfig
}

run(){
  python -m SimpleHTTPServer 9042 >> /tmp/SimpleHTTPServer.log 2>&1
}

send2loggly
set -e
set -x
ports
deploy
run

