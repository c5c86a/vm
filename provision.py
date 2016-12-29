from lib.vultr import Server
from lib.ssh2vm import SSH2VM

from requests import post, get
from time import sleep

class Provisioner:
    srv = None
    vm = None
    label = None
    def _init__(self, label):
        self.label = label
        self.srv = Server()
        ip = self.srv.create(label)
        try:
            self.vm = SSH2VM(ip)
            assert self.vm.is_reachable(), "VM is not reachable with ssh"
            print('is reachable')
            self.vm.upload("deploy/%s-install.sh" % label)
            self.vm.upload("deploy/%s-entrypoint.sh" % label)
            self.vm.execute("bash +x %s-install.sh" % label)
        finally:
            self.srv.destroy()
    def start():
        try:
            self.vm.daemon("bash +x %s-entrypoint.sh" % self.label)
            sleep(4)
            print get("http://%s:8080" % ip).text
        finally:
            self.srv.destroy()


def main():
    Provisioner('smsc').start()


if __name__ == "__main__":
    main()
