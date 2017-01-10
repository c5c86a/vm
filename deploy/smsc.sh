#!/bin.sh

apt-get install -y python ufw

ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 8080/tcp
ufw allow 443/tcp  # HTTPS
# access to docker provisioner
ufw allow 2376/tcp # docker daemon
ufw allow 3376/tcp # Swarm API
ufw allow 4789/udp # VXLAN
ufw --force enable

curl -sSL https://get.docker.com/ | sh

echo "finished smsc.sh" >> /log.txt
python -m SimpleHTTPServer 8080 
