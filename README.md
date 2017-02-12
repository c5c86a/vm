[![Travis build status](https://travis-ci.org/nicosmaris/vm.png?branch=master)](https://travis-ci.org/nicosmaris/vm)

#### vm

Note that this repository is experimental and there is no plan yet of packaging it to pip.

If you are a developer and you need the following, this minimal python library might help you.

1. a demo of your software
2. a few virtual machines in an automated setup to minimize cost of VM and risk of human error. You want Vultr because it is a cheap cloud provider but you don't want to learn its API.
3. you don't want to learn any orchestration platform

Whether you use docker or not, in this case you don't need Kubernetes, Mesosphere, Docker Swarm or even Ansible, Puppet, Chef or Salt.

We assume that you know enough bash and python to adapt this library to your needs.

Before adding any feature like networks, backup or coding in Go, you should keep in mind that the goal is to keep this library to a minimum without making yet another orchestration platform.
If your needs become bigger, you should use an orchestration platform and by that time you will know which scripts belong to the developer and which scripts belong to the devop.

However, contributions on testing, logging and error handling are more than welcome.

#### Features

1. Create VMs at vultr in parallel
2. Wait until port is listening
3. Show logs if a port is not listening until a given timeout

#### Requirements

1. pip install -r requirements.txt
2. private key (unversioned...) at a file named `key` at current directory
3. token of an account at vultr (unversioned...) at a file named `token` at current directory

#### Input

The file input.yml should define one or more servers. Each server should have a boot script or a start script or both.

1. A boot script runs on boot. Services if any can start with a bash command
2. A start script is uploaded after boot port is up and then it is executed. Services if any should start with a tool like systemd

Examples of scripts can be found at the folder deploy. Note that the script install_docker.sh starts before all and installs the docker engine.

testinfra --hosts=1.1.1.1
