#!/bin.sh

apt-get update
apt-get install -y python

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

groupadd docker
usermod -aG docker root
curl -sSL https://get.docker.com/ | sh

echo "finished smsc.sh" >> /log.txt
python -m SimpleHTTPServer 8080 
