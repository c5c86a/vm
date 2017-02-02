
set -e

ports(){
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow ssh
  ufw allow 3435/tcp # ss7 cli
  ufw allow 443/tcp  # HTTPS
  # access to docker provisioner
  ufw allow 2376/tcp # docker daemon
  ufw allow 3376/tcp # Swarm API
  ufw allow 4789/udp # VXLAN
  ufw allow 4243/tcp
  sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
  ufw --force enable
}

run(){
  mkdir -p /usr/lib/systemd/system
  cat <<EOT >> /usr/lib/systemd/system/ss7.service
[Unit]
Description=ss7
After=network.target ss7.socket
Requires=ss7.socket

[Service]
ExecStart=python -m SimpleHTTPServer 3435

[Install]
WantedBy=multi-user.target
EOT
  cat <<EOT >> /usr/lib/systemd/system/ss7.socket
[Unit]
Description=SS7
PartOf=ss7.service

[Socket]
ListenStream=0.0.0.0:3435

[Install]
WantedBy=sockets.target
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

