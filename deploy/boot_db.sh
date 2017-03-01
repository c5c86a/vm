#!/bin/bash

echo "boot db"

export DEBIAN_FRONTEND=noninteractive

send2loggly(){
  if [ -f /root/loggly_token ]; then
    if [ ! -f configure-linux.sh ]; then
        curl -O https://www.loggly.com/install/configure-linux.sh
    fi
    sudo bash configure-linux.sh -a nicosmaris -t $(cat /root/loggly_token) -u nicos -p $(cat /root/loggly_password)
    sudo sed -i '/ForwardToSyslog/c\ForwardToSyslog=Yes' /etc/systemd/journald.conf
#    exec > >(logger -p boot.info) 2> >(logger -p boot.warn)
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
ports
deploy
run

