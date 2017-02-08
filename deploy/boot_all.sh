#!/bin/bash

set -e

echo "boot db"

export DEBIAN_FRONTEND=noninteractive

ports(){
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow ssh
  ufw allow 9042/tcp # cassandra
  ufw allow 9160/tcp # cassandra
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
  docker run --name db --net=host -p 127.0.0.1:9042:9042 -p 127.0.0.1:9160:9160 -e "CASSANDRA_LISTEN_ADDRESS=127.0.0.1" -e "MAX_HEAP_SIZE=128M" -e "HEAP_NEWSIZE=24M" -d cassandra:2.0 >> /tmp/db.log 2>&1
  docker run --name smsc --net=host -p 127.0.0.1:8080:8080 -p 127.0.0.1:3435:3435 -d restcomm/smscgateway-docker >> /tmp/smsc.log 2>&1
}

ports
deploy
run

