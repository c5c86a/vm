[![Travis build status](https://travis-ci.org/nicosmaris/vm.png?branch=master)](https://travis-ci.org/nicosmaris/vm)

# vm

This minimal python library helps you set up a network of a few virtual machines
without the learning curve of orchestration platforms like Kubernetes, Mesosphere and Docker Swarm.

1. Create VMs at vultr in parallel
2. Wait until port is listening
3. Show logs if a port is not listening until a given timeout
4. Optionally, destroy VMs in the end (for use at CI)

```
key: path_to_private_key
vultr: path_to_vultr_token
loggly: path_to_loggly_token_if_any
servers:
  - startup: path_to_startup_script_if_any 
    logs: path to logs, if any
    startup_ports: 8080
    name: server
  - startup: path_to_startup_script_if_any 
    logs: path to logs, if any
    startup_ports: 22
    name: client
    script: path to script to replace dependency with ip, upload it and run it. if any
    dependency:
        db: server
    script_ports: 22
```