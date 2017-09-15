#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

install_saltstack(){
curl -L https://bootstrap.saltstack.com -o install_salt.sh
sudo sh install_salt.sh -P -M -L # The -L option will install salt-cloud
}

dpkg -s salt-cloud || install_saltstack

