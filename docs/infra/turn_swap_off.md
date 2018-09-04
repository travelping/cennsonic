# Turn Swap Off

Kubernetes does not support work with swap therefore it should be turned of
prior to deployment.

Run this command to turn it off:

```
$ cd <Cluster Root Path>
$ nfv-k8s disable-swap
    [-k,--ask-pass] # if SSH password should be specified
    [-K,--ask-become-pass] # if "sudo" password should be specified
    [--pk,--private-key=<Path>] # if SSH private key should be specified
```

without "nfv-k8s":

```
$ cd <Cluster Root Path>
$ docker run \
        --rm -it \
        -v $PWD/config:/cluster/config \
        [-v $HOME/.ssh/id_rsa:/root/.ssh/key \] # if SSH private key should be specified
        travelping/nfv-k8s ansible-playbook disable-swap.yml \
        -vbi /cluster/config/hosts.ini
        [-k or --ask-pass] # if SSH password should be specified
        [-K or --ask-become-pass] # if "sudo" password should be specified
        [--key-file /root/.ssh/key] # if SSH private key should be specified
```
