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
  echo "CASSANDRA_IP=\"$CASSANDRA_IP\"" > /root/envconfurl
  mkdir -p /usr/lib/systemd/system
  cat <<EOT >> /usr/lib/systemd/system/ss7.service
[Unit]
Description=ss7
[Service]
Type=simple
EnvironmentFile=/root/envconfurl
ExecStart=/usr/bin/docker run --name smsc -e SMSC_SERVER="simulator" -e CASSANDRA_IP="$CASSANDRA_IP" --net=host -p 0.0.0.0:8080:8080 -p 0.0.0.0:3435:3435 -d nicosmaris/smscgateway-docker
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

