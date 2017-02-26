#!/bin/bash

set -e

send2loggly(){
  if [ -f /root/loggly_token ]; then
    if [ ! -f configure-linux.sh ]; then
        curl -O https://www.loggly.com/install/configure-linux.sh
    fi
    sudo bash configure-linux.sh -a nicosmaris -t $(cat /root/loggly_token) -u nicos -p $(cat loggly_password)
    sudo sed -i '/ForwardToSyslog/c\ForwardToSyslog=Yes' /etc/systemd/journald.conf
    exec 1> >(logger -s -t $(basename $0)) 2>&1
  fi
}

ports(){
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow ssh
  ufw allow 3435/tcp # ss7 cli
  sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
  ufw --force enable
}

run(){
  mkdir -p /usr/lib/systemd/system
  cat <<EOT >> /usr/lib/systemd/system/ss7.service
[Unit]
Description=ss7
[Service]
Type=simple
ExecStart=/usr/bin/python -m SimpleHTTPServer 3435
[Install]
WantedBy=multi-user.target
EOT

  systemctl daemon-reload
  systemctl enable ss7
  systemctl start ss7
  systemctl status ss7
}

send2loggly

echo "curl -X GET http://$CASSANDRA_IP:9042"

curl -X GET http://$CASSANDRA_IP:9042

echo "start ss7cli"
ports
run

