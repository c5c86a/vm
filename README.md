[![Travis build status](https://travis-ci.org/nicosmaris/vm.png?branch=ship)](https://travis-ci.org/nicosmaris/vm)

#### TODO

add ssh key
loggly for agent and VMs
healthcheck

#### vm

This library creates VMs at Vultr given in a .yml file and runs bash scripts on them without asking the developer to have devops skills.

It is similar to Ansible but only for demonstration or CI purposes. In other words, you won't gain idempotence but you won't need to check the systax.

There is no complex declarative syntax and we assume that you know enough bash and javascript to adapt this library to your needs:

1. If you want to check that a condition is true, you should extend the python module 'shipitfile.js' by waiting for the condition to be true until a timeout then the resulting event should be emitted.
2. Every useful progress report should be at stdout


#### Features

If you are a developer and you need the following, this minimal python library might help you.

1. a demo of your software
2. a few virtual machines in an automated setup to minimize cost of VM and risk of human error. You want Vultr because it is a cheap cloud provider but you don't want to learn its API.
3. you don't want to learn any orchestration platform

Whether you use docker or not, in this case you don't need Kubernetes, Mesosphere, Docker Swarm or even Ansible, Puppet, Chef or Salt.

Some features are:

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

The server name of a dependency is replaced with its IP once all of its ports are listening and all of its log files exist.

#### Contributions

Before adding any feature like networks, backup or coding in Go, you should keep in mind that the goal is to keep this library to a minimum without making yet another orchestration platform.
If your needs become bigger, you should use an orchestration platform and by that time you will know which scripts belong to the developer and which scripts belong to the devop.

However, contributions on testing, logging and error handling are more than welcome.
