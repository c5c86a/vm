#!/bin/bash

set -e

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
Type=forking
ExecStart=/usr/bin/python -m SimpleHTTPServer 3435 &
[Install]
WantedBy=multi-user.target
EOT

  systemctl daemon-reload
  systemctl enable ss7
  systemctl start ss7
  systemctl status ss7
}

echo "curl -X GET http://$CASSANDRA_IP:9042"

curl -X GET http://$CASSANDRA_IP:9042

echo "start ss7cli"
ports
run

