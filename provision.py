from __future__ import print_function
import sys
from lib.vultr import Server
from lib.ssh2vm import SSH2VM

from requests import post, get
from time import sleep
import socket
import errno
from time import time as now


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def wait_net_service(server, port, timeout=None):
    """ Wait for network service to appear
        @param timeout: in seconds
        @return: True of False, if timeout is None may return only True or
                 throw unhandled network exception
    """
    s = socket.socket()
    # time module is needed to calc timeout shared between two exceptions
    end = now() + timeout

    while True:
        eprint("trying to connect to %s at port %d" % (server, port))
        try:
            next_timeout = end - now()  # connect might not respect our timeout so we try again until reaching it
            if next_timeout < 0:
                return False
            else:
                s.settimeout(next_timeout)
            s.connect((server, port))

        except socket.timeout, err:
            return False
        except socket.error, err:
            # catch timeout exception from underlying network library
            if type(err.args) != tuple or err[0] != errno.ETIMEDOUT:
                raise
            else:
                eprint("waiting 10 seconds for %s to open port %d" % (server, port))
                sleep(10)
        else:
            s.close()
            return True

class Provisioner:
    srv = None
    vm = None
    label = None
    ip = None

    def __init__(self, label, plan=29, datacenter=9):
        """
        plan 29 is 768 MB RAM,15 GB SSD,1.00 TB BW and can be found at https://api.vultr.com/v1/plans/list 90 is 3GB at dc 1
        data center 9 is at Frankfurt and each datacenter has specific plans. Data centers list is at https://api.vultr.com/v1/regions/list
        """
        self.label = label
        self.srv = Server()
        self.srv.create(label, plan, datacenter)

    def destroy(self):
        self.srv.destroy()


def main():
    server = None
    client = None
    try:
        server = Provisioner('server')
        client = Provisioner('client')

        server.ip = server.srv.getip()
        client.ip = client.srv.getip()

        for port in [22, 8080]:
            for ip in [server.ip, client.ip]:   # wait until travis is about to kill the job and then fail
                assert wait_net_service(ip, port, 60), "Expected port 8080 of %s to be up" % ip
    finally:
        if server!=None:
           server.destroy()
        if client!=None:
           client.destroy()


if __name__ == "__main__":
    main()
