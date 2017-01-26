#!/bin.sh

set -e

export DEBIAN_FRONTEND=noninteractive

fix_vultr(){
  # vultr starts ubuntu with dpkg locked and without python installed
  killall -we 'apt-get'
  echo "start searching for 'apt-get -qq -y update' initiated by vultr..."
  ps aux | grep '[a]pt'
  echo "stop searching for 'apt-get -qq -y update' initiated by vultr..."
  rm /var/lib/apt/lists/lock
  rm /var/cache/apt/archives/lock
  rm /var/lib/dpkg/lock
  dpkg --configure -a
  apt-get update
}

ports(){
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow ssh
  ufw allow 3435/tcp
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
ports
install_docker

echo "finished smsc.sh" >> /log.txt

apt-get -y install build-essential python-dev git 
wget --no-check-certificate https://bootstrap.pypa.io/ez_setup.py -O - | python - 'setuptools==26.1.1'
wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py -O - | python - 'pip==8.1.2'
#python -m SimpleHTTPServer 8080 

docker run --name db --net=host -p 127.0.0.1:9042:9042 -p 127.0.0.1:9160:9160 -d cassandra:2.0
sleep 20
docker run --name smsc --net=host -e ENVCONFURL="https://raw.githubusercontent.com/RestComm/smscgateway-docker/master/env_files/restcomm_env_smsc_locally.sh" -p 0.0.0.0:8080:8080 -p 0.0.0.0:3435:3435 restcomm/smscgateway-docker

docker exec -ti smsc bash /opt/Restcomm-SMSC/jboss-5.1.0.GA/bin/ss7-cli.sh -h

sleep 660
