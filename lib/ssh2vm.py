from delorean import Delorean
from datetime import timedelta
from time import sleep

from subprocess import Popen, PIPE

from fabric.operations import run, put
from fabric.context_managers import settings
import sys


class SSH2VM:
    def __init__(self, ip):
        self.ip = ip
    def cmd(command):
        array = ["ssh",
               "-i", "key",
               "-o", "StrictHostKeyChecking=no",
               "-o", "KbdInteractiveDevices=no",
               "-o", "BatchMode=yes",
               "%s@%s" % ('root', self.ip),
               "date"]
        pid = Popen(array, stdout=PIPE, stderr=PIPE)
        return pid.communicate()
 
    def is_reachable(self):
        result = False
        array = ["ssh",
               "-i", "key",
               "-o", "StrictHostKeyChecking=no",
               "-o", "KbdInteractiveDevices=no",
               "-o", "BatchMode=yes",
               "%s@%s" % ('root', self.ip),
               "date"]

        first_attempt = Delorean()
        while True:
            if Delorean() - first_attempt < timedelta(minutes=5):
	        sleep(10)
            else:
                pid = Popen(array, stdout=PIPE, stderr=PIPE)
                out, err = pid.communicate()                         # executes command
                if pid.returncode==0:
                    result = True
                    break
        return result
    def upload(self, local_path):
        with settings(host_string='root@'+self.ip, key_filename='key'):
            put(local_path, '')

    def execute(self, command):
        """
        The current timeout for a job on travis-ci.org is 50 minutes (and at least one line printed to stdout/stderr per 10 minutes)
        """
        with settings(host_string='root@'+self.ip, key_filename='key'):
            run(command, stdout=sys.stdout, stderr=sys.stderr)

    def daemon(self, command):
        """
        The current timeout for a job on travis-ci.org is 50 minutes (and at least one line printed to stdout/stderr per 10 minutes)
        """
        with settings(host_string='root@'+self.ip, key_filename='key'):
            run("nohup %s >& /dev/null < /dev/null &" % command, pty=False, stdout=sys.stdout, stderr=sys.stderr) # http://docs.fabfile.org/en/1.5/faq.html


