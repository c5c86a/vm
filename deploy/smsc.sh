#!/bin.sh

apt-get install -y python
curl -sSL https://get.docker.com/ | sh
python -m SimpleHTTPServer 8080
