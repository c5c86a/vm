#!/bin/bash

set -e

ports(){
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow ssh
  ufw allow 3435/tcp # ss7 cli
  ufw allow 9001/tcp
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
  echo "directory=/srv" >> /etc/supervisor/conf.d/ss7.conf
  echo "autostart=true" >> /etc/supervisor/conf.d/ss7.conf
  echo "autorestart=true" >> /etc/supervisor/conf.d/ss7.conf
  echo "startretries=3" >> /etc/supervisor/conf.d/ss7.conf
  echo "stderr_logfile=/var/log/webhook/nodehook.err.log" >> /etc/supervisor/conf.d/ss7.conf
  echo "stdout_logfile=/var/log/webhook/nodehook.out.log" >> /etc/supervisor/conf.d/ss7.conf
  echo "user=www-data" >> /etc/supervisor/conf.d/ss7.conf
  echo "environment=CASSANDRA_IP='$CASSANDRA_IP'" >> /etc/supervisor/conf.d/ss7.conf
  echo "[inet_http_server]" >> /etc/supervisor/conf.d/ss7.conf
  echo "port = 9001" >> /etc/supervisor/conf.d/ss7.conf
  echo "username = user # Basic auth username" >> /etc/supervisor/conf.d/ss7.conf
  echo "password = pass # Basic auth password" >> /etc/supervisor/conf.d/ss7.conf

  sudo service supervisor start
  supervisorctl reread
  supervisorctl update
  ps aux | grep python
}

echo "curl -X GET http://$CASSANDRA_IP:9042"

curl -X GET http://$CASSANDRA_IP:9042

echo "start ss7cli"
ports
run

