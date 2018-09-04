# Disable Sudo Password

Cluster deployment and further operations require privileged access that is
often get by "sudo" that might require password. If you wish to avoid asking
for password you can disable it.

Run this command to disable sudo password:

```
$ cd <Cluster Root Path>
$ nfv-k8s disable-sudo -K
    [-k,--ask-pass] # if SSH password should be specified
    [--pk,--private-key=<Path>] # if SSH private key should be specified
```

without "nfv-k8s":

```
$ cd <Cluster Root Path>
$ docker run \
        --rm -it \
        -v $PWD/config:/cluster/config \
        [-v $HOME/.ssh/id_rsa:/root/.ssh/key \] # if SSH private key should be specified
        travelping/nfv-k8s ansible-playbook disable-sudo.yml \
        -vbi /cluster/config/hosts.ini -K
        [-k or --ask-pass] # if SSH password should be specified
        [--key-file /root/.ssh/key] # if SSH private key should be specified
```
