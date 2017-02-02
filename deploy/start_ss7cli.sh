
set -e

ports(){
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow ssh
  ufw allow 3435/tcp # ss7 cli
  ufw allow 9001/tcp
  ufw allow 443/tcp  # HTTPS
  # access to docker provisioner
  ufw allow 2376/tcp # docker daemon
  ufw allow 3376/tcp # Swarm API
  ufw allow 4789/udp # VXLAN
  ufw allow 4243/tcp
  sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
  ufw --force enable
}
#[unix_http_server]
#file = /tmp/supervisor.sock
#chmod = 0777
#chown= mywebsiteuser:mywebsiteusergroup
#
#[supervisord]
#logfile = /tmp/supervisord.log
#logfile_maxbytes = 50MB
#logfile_backups=10
#loglevel = info
#pidfile = /tmp/supervisord.pid
#nodaemon = false
#minfds = 1024
#minprocs = 200
#umask = 022
#user = mywebsiteuser
#identifier = supervisor
#directory = /tmp
#nocleanup = true
#childlogdir = /tmp
#strip_ansi = false
#
#[supervisorctl]
#serverurl = http://localhost:9001

run(){
  sudo apt-get install -y supervisor
  cat <<EOT >> /etc/supervisor/conf.d/ss7.conf
[program:ss7]
command=python -m SimpleHTTPServer 3435 2> /var/log/supervisord/simplehttpserver.err.log 1> /var/log/supervisord/simplehttpserver.out.log
directory=/
stderr_logfile=/var/log/supervisord/simplehttpserver.err.log
stdout_logfile=/var/log/supervisord/simplehttpserver.out.log
environment=CASSANDRA_IP='$CASSANDRA_IP'

[inet_http_server]
port = 9001
username = user
password = pass
EOT

  supervisorctl -c /etc/supervisord.conf reload
  supervisorctl -c /etc/supervisord.conf start ss7:*
  ps aux | grep python
}

echo "curl -X GET http://$CASSANDRA_IP:9042"

curl -X GET http://$CASSANDRA_IP:9042

echo "start ss7cli"
ports
run

