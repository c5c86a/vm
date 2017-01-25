#!/bin.sh

set -e

export DEBIAN_FRONTEND=noninteractive
killall -we 'apt-get'
echo "start searching for 'apt-get -qq -y update' initiated by vultr..."
ps aux | grep '[a]pt'
echo "stop searching for 'apt-get -qq -y update' initiated by vultr..."
rm /var/lib/apt/lists/lock
rm /var/cache/apt/archives/lock
rm /var/lib/dpkg/lock
dpkg --configure -a
apt-get update

ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 8080/tcp
ufw allow 443/tcp  # HTTPS
# access to docker provisioner
ufw allow 2376/tcp # docker daemon
ufw allow 3376/tcp # Swarm API
ufw allow 4789/udp # VXLAN
ufw allow 4243/tcp
sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw 
ufw --force enable

# uncomment due to docker/issues/23365#issuecomment-224638271
sed -i '/^#SYS_GID_MIN/s/^#//g' /etc/login.defs
sed -i '/^#SYS_GID_MAX/s/^#//g' /etc/login.defs

# ubuntu 16.04
mkdir -p /lib/systemd/system
echo '[Unit]' >> /lib/systemd/system/docker.service
echo 'Description=Docker Application Container Engine' >> /lib/systemd/system/docker.service
echo 'Documentation=https://docs.docker.com' >> /lib/systemd/system/docker.service
echo 'After=network.target docker.socket firewalld.service' >> /lib/systemd/system/docker.service
echo 'Requires=docker.socket' >> /lib/systemd/system/docker.service
echo '' >> /lib/systemd/system/docker.service
echo '[Service]' >> /lib/systemd/system/docker.service
echo 'Type=notify' >> /lib/systemd/system/docker.service
echo 'EnvironmentFile=-/etc/default/docker' >> /lib/systemd/system/docker.service
echo 'ExecStart=/usr/bin/dockerd $DOCKER_OPTS' >> /lib/systemd/system/docker.service
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

apt-get update
apt-get -y install curl linux-image-extra-$(uname -r) linux-image-extra-virtual
apt-get -y install apt-transport-https ca-certificates
curl -fsSL https://yum.dockerproject.org/gpg | sudo apt-key add -
add-apt-repository \
       "deb https://apt.dockerproject.org/repo/ \
       ubuntu-$(lsb_release -cs) \
       main"
apt-get update
apt-get -y install docker-engine || true

# ubuntu 16.04
mkdir -p /lib/systemd/system
echo '[Unit]' >> /lib/systemd/system/docker.service
echo 'Description=Docker Application Container Engine' >> /lib/systemd/system/docker.service
echo 'Documentation=https://docs.docker.com' >> /lib/systemd/system/docker.service
echo 'After=network.target docker.socket firewalld.service' >> /lib/systemd/system/docker.service
echo 'Requires=docker.socket' >> /lib/systemd/system/docker.service
echo '' >> /lib/systemd/system/docker.service
echo '[Service]' >> /lib/systemd/system/docker.service
echo 'Type=notify' >> /lib/systemd/system/docker.service
echo 'EnvironmentFile=-/etc/default/docker' >> /lib/systemd/system/docker.service
echo 'ExecStart=/usr/bin/dockerd $DOCKER_OPTS' >> /lib/systemd/system/docker.service
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
systemctl status docker.service
adduser user
usermod -aG docker user
service docker restart

docker run -d hello-world
docker ps -a

echo "finished smsc.sh" >> /log.txt
python -m SimpleHTTPServer 8080 
