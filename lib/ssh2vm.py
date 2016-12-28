from delorean import Delorean
from datetime import timedelta
from time import sleep

from subprocess import Popen, PIPE

from fabric.api import env
from fabric.operations import run, put


class SSH2VM:
    def __init__(self, ip):
        self.ip = ip
        env.hosts = [ip]
        env.user = 'root'
        env.key_filename = 'key'
    def is_reachable(self):
        result = False
        command = 'date'
        array = ["ssh",
               "-i", "key",
               "-o", "StrictHostKeyChecking=no",
               "-o", "KbdInteractiveDevices=no",
               "-o", "BatchMode=yes",
               "%s@%s" % ('root', self.ip)]
        array.append(command.split(' '))

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
    def upload(local_path):
        put(local_path, '')

    def execute(local_path):
        """
        The current timeout for a job on travis-ci.org is 50 minutes (and at least one line printed to stdout/stderr per 10 minutes)
        """
        run(local_path, '')

