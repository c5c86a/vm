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
        self.vm = SSH2VM(self.ip)
        assert self.vm.is_reachable(), "VM is not reachable with ssh"
        print('is reachable')

    def destroy(self):
        self.srv.destroy()


def main():
    vm = None
    try:
        vm = Provisioner('smsc')
        print('sleeping for 60 sec')
        sleep(60)
        self.vm.execute("cat /log.txt")
    finally:
        vm.destory()


if __name__ == "__main__":
    main()
