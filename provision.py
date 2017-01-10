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
        self.srv.create(label)

    def getip(self):
        """
        Compared to vultr.Server.getip this method makes sure that the VM can be accessed by ssh
        """
        self.ip = self.srv.getip()
        self.vm = SSH2VM(self.ip)
        assert self.vm.is_reachable(), "VM is not reachable with ssh"
        print('is reachable')
        while True:
            result = self.vm.execute("grep done /tmp/firstboot.log")
            if Delorean() - self.srv.startuptime < timedelta(minutes=1):
                if result.succeded:
                    break
                eprint("Waiting for startup script %s to have the keyword done" % self.label)
                sleep(10)
            else:
                self.vm.execute("cat /tmp/firstboot.log")
                assert False, "VM started but script failed"
        return self.ip
 

    def destroy(self):
        self.srv.destroy()


def main():
    p = None
    try:
        p = Provisioner('smsc')
        p.getip()
        p.vm.execute("cat /tmp/firstboot.log")
    finally:
        p.destroy()


if __name__ == "__main__":
    main()
