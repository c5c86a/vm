#!/bin/bash

curl --header "API-key: $(cat token)" https://api.vultr.com/v1/sshkey/list
