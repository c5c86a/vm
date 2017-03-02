#!/bin/bash

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
StandardOutput=/tmp/out.log
StandardError=/tmp/err.log
[Install]
WantedBy=multi-user.target
EOT

  systemctl daemon-reload
  systemctl enable ss7
  systemctl start ss7
  systemctl status ss7
}

exec > /root/startapp.log 2>&1
set -e
set -x

echo "curl -X GET http://$CASSANDRA_IP:9042"

curl -X GET http://$CASSANDRA_IP:9042

echo "start ss7cli"
ports
run

curl -O https://www.loggly.com/install/configure-file-monitoring.sh
bash configure-file-monitoring.sh -s -a nicosmaris -t $(cat /root/loggly_token) -u nicos -p $(cat /root/loggly_password) -f /tmp -l `hostname`
