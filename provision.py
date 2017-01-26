from lib.vultr import Server
from lib.ssh2vm import SSH2VM

from requests import post, get
from time import sleep

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
        self.ip = self.srv.create(label, plan, datacenter)
        self.vm = SSH2VM(self.ip)
        assert self.vm.is_reachable(), "VM is not reachable with ssh"
        print('is reachable')

    def destroy(self):
        self.srv.destroy()


def main():
    server = None
    client = None
    try:
        server = Provisioner('server')
        client = Provisioner('client')
        right = (client.ip, server.ip)
        left = (server.ip, client.ip)
        client.vm.execute("%s: ping -c 4 %s" % right)
        server.vm.execute("%s: ping -c 4 %s" % left)
        client.vm.execute("%s: curl -X GET http://%s:8080" % right)
        server.vm.execute("%s: curl -X GET http://%s:8080" % left)
    finally:
        if server!=None:
           server.destroy()
        if client!=None:
           client.destroy()


if __name__ == "__main__":
    main()
