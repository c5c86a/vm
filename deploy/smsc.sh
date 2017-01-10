#!/bin.sh

# The last 3 ports are for access to docker daemon, Swarm API and VXLAN

sleep 2
apt-get install -y python ufw && \
curl -sSL https://get.docker.com/ | sh && \
ufw default deny incoming && \
ufw default allow outgoing && \
ufw allow ssh && \
ufw allow 8080/tcp && \
ufw allow 443/tcp && \
ufw allow 2376/tcp && \ 
ufw allow 3376/tcp && \
ufw allow 4789/udp && \
ufw --force enable && \
echo "done" >> /log.txt && \
python -m SimpleHTTPServer 8080 
