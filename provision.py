from lib.vultr import Server
from lib.ssh2vm import SSH2VM


def main():
    s = Server()
    ip = s.create('travis')
    try:
        vm = SSH2VM(ip)
        assert vm.is_reachable(), "VM is not reachable with ssh"
        print('is reachable')
        vm.upload('deploy/smsc.sh')
        vm.execute('bash +x smsc.sh')
    finally:
        s.destroy()


if __name__ == "__main__":
    main()
