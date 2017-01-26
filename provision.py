from lib.vultr import Server
from lib.ssh2vm import SSH2VM

from requests import post, get
from time import sleep

class Provisioner:
    srv = None
    vm = None
    label = None
    ip = None

    def __init__(self, label, plan=29):
        """
        plan 29 is 768 MB RAM,15 GB SSD,1.00 TB BW and can be found at https://api.vultr.com/v1/plans/list
        """
        self.label = label
        self.srv = Server()
        self.ip = self.srv.create(label, plan)
        self.vm = SSH2VM(self.ip)
        assert self.vm.is_reachable(), "VM is not reachable with ssh"
        print('is reachable')

    def destroy(self):
        self.srv.destroy()


def main():
    p = None
    try:
        p = Provisioner('smsc', 90)
        p.vm.execute("tail -F /tmp/firstboot.log")
    finally:
        if p!=None:
            p.destroy()


if __name__ == "__main__":
    main()
