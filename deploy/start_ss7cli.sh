#!/bin/bash

set -e

ports(){
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow ssh
  ufw allow 3435/tcp # ss7 cli
  ufw allow 8080/tcp
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
  sudo apt-get install -y supervisor
  echo "[program:ss7]" >> /etc/supervisor/conf.d/ss7.conf
  echo "command=python -m SimpleHTTPServer 3435" >> /etc/supervisor/conf.d/ss7.conf
  echo "autorestart=true" >> /etc/supervisor/conf.d/ss7.conf
  supervisord -c /etc/supervisor/conf.d/ss7.conf
}

echo "curl -X GET http://$CASSANDRA_IP:9042"

curl -X GET http://$CASSANDRA_IP:9042

echo "start ss7cli"
ports
run

