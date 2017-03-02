#!/bin/bash

echo "install docker"

echo logglytoken > /root/loggly_token
echo logglypassword > /root/loggly_password

export DEBIAN_FRONTEND=noninteractive

sendtologgly(){
  if [ -f /root/loggly_token ]; then
    cat <<EOT >> /etc/rsyslog.d/21-prepare.conf
\$ModLoad imfile
\$template msg,"<%PRI%>%timegenerated% %HOSTNAME% %syslogtag% %msg%"

# File access
\$InputFileName /tmp/firstboot.log
\$InputFileTag prepare.firstboot:
\$InputFileStateFile stat-firstboot-Monitor
\$InputFileSeverity info
\$InputFileFacility local7
\$InputFilePollInterval 1
\$InputFilePersistStateInterval 1
\$InputRunFileMonitor
# File access
\$InputFileName /root/startapp.log
\$InputFileTag prepare.startapp:
\$InputFileStateFile stat-startapp-Monitor
\$InputFileSeverity info
\$InputFileFacility local7
\$InputFilePollInterval 1
\$InputFilePersistStateInterval 1
\$InputRunFileMonitor
# File access
\$InputFileName /tmp/travis.log
\$InputFileTag prepare.travis:
\$InputFileStateFile stat-travis-Monitor
\$InputFileSeverity info
\$InputFileFacility local7
\$InputFilePollInterval 1
\$InputFilePersistStateInterval 1
\$InputRunFileMonitor

if \$syslogtag contains 'prepare.' and \$syslogfacility-text == 'local7' then @@LOGTRUST-RELAY:PORT;msg
:syslogtag, contains, "prepare." ~
EOT
    sudo sed -i '/ForwardToSyslog/c\ForwardToSyslog=Yes' /etc/systemd/journald.conf
    sudo systemctl restart systemd-journald
    sudo sed -i '/KLogPermitNonKernelFacility/\#KLogPermitNonKernelFacility' /etc/rsyslog.conf
    sudo sed -i '/\$PrivDropToUser syslog/\$PrivDropToUser adm' /etc/rsyslog.conf
    sudo sed -i '/xconsole/console' /etc/rsyslog.d/50-default.conf
    service rsyslog restart
    rsyslogd -version
    rsyslogd -N1
  fi
}

fix_vultr(){
  # vultr starts ubuntu with dpkg locked (/var/log/unattended-upgrades/*) and without python installed
  killall -we 'apt-get'
  echo "start searching for 'apt-get -qq -y update' initiated by vultr..."
  ps aux | grep '[a]pt'
  echo "stop searching for 'apt-get -qq -y update' initiated by vultr..."
  rm /var/lib/apt/lists/lock
  rm /var/cache/apt/archives/lock
  rm /var/lib/dpkg/lock
  dpkg --configure -a
#  apt-get update
}

install_docker(){
  # uncomment due to docker/issues/23365#issuecomment-224638271
  sed -i '/^#SYS_GID_MIN/s/^#//g' /etc/login.defs
  sed -i '/^#SYS_GID_MAX/s/^#//g' /etc/login.defs

  apt-get update
  apt-get -y install curl linux-image-extra-$(uname -r) linux-image-extra-virtual
  apt-get -y install apt-transport-https ca-certificates
  curl -fsSL https://yum.dockerproject.org/gpg | sudo apt-key add -
  add-apt-repository "deb https://apt.dockerproject.org/repo/ ubuntu-$(lsb_release -cs) main"
  apt-get update
  apt-get -y install docker-engine || true

  # ubuntu 16.04
  mkdir -p /lib/systemd/system
  echo '[Unit]' > /lib/systemd/system/docker.service
  echo 'Description=Docker Application Container Engine' >> /lib/systemd/system/docker.service
  echo 'Documentation=https://docs.docker.com' >> /lib/systemd/system/docker.service
  echo 'After=network.target docker.socket firewalld.service' >> /lib/systemd/system/docker.service
  echo 'Requires=docker.socket' >> /lib/systemd/system/docker.service
  echo '' >> /lib/systemd/system/docker.service
  echo '[Service]' >> /lib/systemd/system/docker.service
  echo 'Type=notify' >> /lib/systemd/system/docker.service
  echo 'ExecStart=/usr/bin/dockerd -H fd://' >> /lib/systemd/system/docker.service
  echo 'ExecReload=/bin/kill -s HUP $MAINPID' >> /lib/systemd/system/docker.service
  echo 'LimitNOFILE=1048576' >> /lib/systemd/system/docker.service
  echo 'LimitNPROC=infinity' >> /lib/systemd/system/docker.service
  echo 'LimitCORE=infinity' >> /lib/systemd/system/docker.service
  echo 'TasksMax=infinity' >> /lib/systemd/system/docker.service
  echo 'TimeoutStartSec=0' >> /lib/systemd/system/docker.service
  echo 'Delegate=yes' >> /lib/systemd/system/docker.service
  echo 'KillMode=process' >> /lib/systemd/system/docker.service
  echo '' >> /lib/systemd/system/docker.service
  echo '[Install]' >> /lib/systemd/system/docker.service
  echo 'WantedBy=multi-user.target' >> /lib/systemd/system/docker.service

  systemctl daemon-reload
  systemctl start docker.service
  sleep 10

  adduser user
  usermod -aG docker user
  service docker restart

  docker run -d hello-world
  docker ps -a
}

fix_vultr
install_docker
#sendtologgly