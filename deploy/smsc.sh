#!/bin.sh

export DEBIAN_FRONTEND=noninteractive
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

apt-get -y install docker.io
ln -sf /usr/bin/docker.io /usr/local/bin/docker
sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io
service docker.io restart
update-rc.d docker.io defaults

docker run -d hello-world
docker ps -a

echo "finished smsc.sh" >> /log.txt
python -m SimpleHTTPServer 8080 
