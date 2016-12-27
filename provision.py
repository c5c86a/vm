from lib.vultr import Server
from lib.ssh2vm import SSH2VM


def main():
    s = Server()
    ip = s.create('travis')
    try:
        vm = SSH2VM(ip)
        if vm.is_reachable():
            print('is reachable')
            vm.upload('deploy/smsc.sh')
            vm.execute('bash +x smsc.sh')
        else:
            print('is not reachable')
    finally:
        s.destroy()


if __name__ == "__main__":
    main()
