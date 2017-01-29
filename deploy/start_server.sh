#!/bin.sh

set -e

curl -X GET http://$CASSANDRA_IP:9042

run(){
  python -m SimpleHTTPServer 8080
}

run

