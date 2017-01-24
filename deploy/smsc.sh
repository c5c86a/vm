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

apt-get update
apt-get -y install curl linux-image-extra-$(uname -r) linux-image-extra-virtual
apt-get -y install docker-engine
adduser user
usermod -aG docker user
service docker restart

docker run -d hello-world
docker ps -a

echo "finished smsc.sh" >> /log.txt
python -m SimpleHTTPServer 8080 
