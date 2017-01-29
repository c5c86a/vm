#!/bin.sh

set -e

curl -X GET http://$CASSANDRA_IP:8080

run(){
  python -m SimpleHTTPServer 8081
}

run

