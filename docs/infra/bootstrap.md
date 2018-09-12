# Bootstrap

Basic operations does not include this step although might require it. The
bootstrapping installs Python to the hosts to be able running Ansible roles.

To bootstrap the hosts:


```
$ cd <Cluster Root Path>
$ cennsonic bootstrap
    [-k,--ask-pass] # if SSH password should be specified
    [-K,--ask-become-pass] # if "sudo" password should be specified
    [--pk,--private-key=<Path>] # if SSH private key should be specified
```

without "cennsonic":

```
$ cd <Cluster Root Path>
$ docker run \
        --rm -it \
        -v $PWD/config:/cluster/config \
        [-v $HOME/.ssh/id_rsa:/root/.ssh/key \] # if SSH private key should be specified
        travelping/cennsonic ansible-playbook bootstrap.yml \
        -vbi /cluster/config/hosts.ini
        [-k or --ask-pass] # if SSH password should be specified
        [-K or --ask-become-pass] # if "sudo" password should be specified
        [--key-file /root/.ssh/key] # if SSH private key should be specified
```
