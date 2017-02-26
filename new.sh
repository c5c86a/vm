#!/bin/bash

#curl -X POST -H "API-key: $(cat token)" https://api.vultr.com/v1/sshkey/create?name=tmp&sshkey="$(cat otp.pub)"
curl -X POST -H "API-key: $(cat token)" --data "name='tmp'" --data "sshkey=$(cat otp.pub)" https://api.vultr.com/v1/sshkey/create

#curl --header "API-key: $(cat token)" https://api.vultr.com/v1/sshkey/list
