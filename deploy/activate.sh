#!/usr/bin/env bash

deploy(){
  echo "this can be overwritten with a function that deploys everything and prints only to stdout and stderr"
}

vars(){
  echo "PORT=8080"
}

servicename(){
  echo "simplehttpserver"
}

service(){
  echo "this should be overwritten with a function that starts the service in the background. It might depend on environment variables whose values are stored at file. It prints only to stdout and stderr."
}

healthcheck(){
  echo "this can be overwritten with a function that checks whether the service is ready to be used and prints only to stdout and stderr"
}
###############################################################
service(){
  python -m SimpleHTTPServer $1
}

###############################################################

daemonize(){
  dir=$PWD
  envfile=/etc/env
  sudo vars > $envfile
  mkdir -p /usr/lib/systemd/system
  name=$(servicename)
  sudo bash -c "cat >> /usr/lib/systemd/system/$name.service" << EOL
[Unit]
Description=$name
[Service]
Type=simple
EnvironmentFile=$envfile
ExecStart=/bin/bash -c "source $dir/activate.sh && service $PORT"
[Install]
WantedBy=multi-user.target
EOL

  sudo systemctl daemon-reload
  sudo systemctl enable $name
  sudo systemctl start $name
  sudo systemctl status $name
}

deploy(){
  # the following file stores only the deployment and the healthcheck. The application logs are at journalctl which can be redirected to rsyslog and loggly for more security
  logfile=/tmp/firstboot.log
  deploy >> $logfile 2>&1
}

startup(){
  # the following file stores only the deployment and the healthcheck. The application logs are at journalctl which can be redirected to rsyslog and loggly for more security
  logfile=/tmp/firstboot.log
  daemonize
  for i in `seq 1 5`;
  do
    healthcheck >> $logfile 2>&1
    sleep 1
  done    
}
