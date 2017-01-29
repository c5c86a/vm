[![Travis build status](https://travis-ci.org/nicosmaris/vm.png?branch=master)](https://travis-ci.org/nicosmaris/vm)

#### vm

If you are a developer and you need the following, this minimal python library might help you.

1. a demo of your software
2. a few virtual machines in an automated setup to minimize cost of VM and risk of human error. You want Vultr because it is a cheap cloud provider but you don't want to learn its API.
3. you don't want to learn any orchestration platform

Whether you use docker or not, in this case you don't need Kubernetes, Mesosphere, Docker Swarm or even Ansible, Puppet, Chef or Salt.

We assume that you know enough bash and python to adapt this library to your needs.

The goal is to keep this library to a minimum without making yet another orchestration platform.
If your needs become bigger, you should use an orchestration platform and by that time you will know which scripts belong to the developer and which scripts belong to the devop.

#### Features

1. Create VMs at vultr in parallel
2. Wait until port is listening
3. Show logs if a port is not listening until a given timeout

#### Requirements

1. pip install -r requirements.txt
2. private key (unversioned...) at a file named `key` at current directory
3. token of an account at vultr (unversioned...) at a file named `token` at current directory

#### Input

For each argument x that you put at class Provisioner, you can put the following files at folder deploy.

1. boot_x.sh runs on boot
2. start_x.sh is uploaded after startup_x.sh is ready and then it is executed

The file input.yml has the following format:

```
servers:
  - name: server
    boot:                             (optional)
        logs:                         (optional, if they are given, their content is shown in case of error)
        - 'full path to a log file'
        ports: 8080                   (waits until these ports are up. mandatory if there is a boot_x.sh)
    start:                            (optional)
        logs:                         (optional, if they are given, their content is shown in case of error)
        - 'full path to a log file'
        ports: 8080                   (waits until these ports are up. mandatory if there is a start_x.sh)
        dependencies:                 (optional)
            db: server                (sets env var db with value the IP of the server with name 'server')
    ci: true                          (optional, if true, it destroys VMs in the end, default is false)
```