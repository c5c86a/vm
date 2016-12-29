from lib.vultr import Server
from lib.ssh2vm import SSH2VM

from requests import post, get
from time import sleep

class Provisioner:
    srv = None
    vm = None
    label = None
    ip = None
    def __init__(self, label):
        self.label = label
        self.srv = Server()
        self.ip = self.srv.create(label)
        try:
            self.vm = SSH2VM(self.ip)
            assert self.vm.is_reachable(), "VM is not reachable with ssh"
            print('is reachable')
        finally:
            self.srv.destroy()
    def destroy(self):
        try:
            sleep(60)
            self.vm.execute("cat /log.txt")
            print get("http://%s:8080" % self.ip).text
        finally:
            self.srv.destroy()


def main():
    Provisioner('smsc').destroy()


if __name__ == "__main__":
    main()
