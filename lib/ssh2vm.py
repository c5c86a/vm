from __future__ import print_function

import sys
import socket
from errno import ETIMEDOUT, ECONNABORTED, ECONNREFUSED

from delorean import Delorean
from datetime import timedelta
from time import sleep
from time import time as now

from subprocess import Popen, PIPE

from fabric.operations import run, put
from fabric.context_managers import settings, shell_env
from fabric.state import env
from fabric.contrib.files import exists

import sys


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


env.connection_attempts = 5

class SSH2VM:
    def __init__(self, ip):
        self.ip = ip

    def upload(self, local_path):
        with settings(host_string='root@'+self.ip, key_filename='key'):
            put(local_path, '')

    def execute(self, command, env_vars_dict=None):
        """
        The current timeout for a job on travis-ci.org is 50 minutes (and at least one line printed to stdout/stderr per 10 minutes)
        """
        if env_vars_dict==None:
            with settings(host_string='root@'+self.ip, key_filename='key'):
                run(command, stdout=sys.stdout, stderr=sys.stderr, pty=False, timeout=360)
        else:
            with settings(shell_env(**env_vars_dict), host_string='root@' + self.ip, key_filename='key'):
                run(command, stdout=sys.stdout, stderr=sys.stderr, pty=False, timeout=360)

    def wait_net_service(self, port, timeout=None):
        """ Wait for network service to appear
            @param timeout: in seconds
            @return: True of False, if timeout is None may return only True or
                     throw unhandled network exception
        """
        s = socket.socket()
        # time module is needed to calc timeout shared between two exceptions
        end = now() + timeout

        while True:
            eprint("trying to connect to %s at port %d" % (self.ip, port))
            try:
                next_timeout = end - now()  # connect might not respect our timeout so we try again until reaching it
                if next_timeout < 0:
                    return False
                else:
                    s.settimeout(next_timeout)
                s.connect((self.ip, port))

            except socket.timeout, err:
                return False
            except socket.error, err:
                codes = [ETIMEDOUT, ECONNABORTED, ECONNREFUSED]
                if err[0] not in codes:
                    assert False, err
                else:
                    eprint("waiting 10 seconds for %s to open port %d" % (self.ip, port))
                    sleep(10)
            else:

                s.close()
                return True

    def exists(self, fullpath, use_sudo=True):
        result = False
        with settings(host_string='root@'+self.ip, key_filename='key'):
            result = exists(fullpath, use_sudo=use_sudo)
        return result
