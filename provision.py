from lib.vultr import Server
from lib.ssh2vm import SSH2VM

from requests import post, get

def main():
    s = Server()
    ip = s.create('travis')
    try:
        vm = SSH2VM(ip)
        assert vm.is_reachable(), "VM is not reachable with ssh"
        print('is reachable')
        vm.upload('deploy/smsc-install.sh')
        vm.upload('deploy/smsc-entrypoint.sh')
        vm.execute('bash +x smsc-install.sh')
        vm.deamon('bash +x smsc-entrypoint.sh')
        print get("http://%s:8080" % ip).text
    finally:
        s.destroy()


if __name__ == "__main__":
    main()
