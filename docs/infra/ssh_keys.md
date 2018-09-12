# SSH Keys

To manage SSH access on the nodes, i.e. add or remove SSH public keys, open the
"all hosts" configuration file:

```
$ cd <Cluster Root Path>
$ open config/group_vars/all.yml
```

and edit:

* ssh_keys — to add keys
* no_ssh\_keys — to delete existing keys.

Each item will be used as a link to download a key from.

After the changes are ready run this command to actualise the desired SSH keys
state on the cluster nodes (requires [Bootstrap]):

```
$ cd <Cluster Root Path>
$ cennsonic ssh-keys
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
        travelping/cennsonic ansible-playbook ssh-keys.yml \
        -vbi /cluster/config/hosts.ini
        [-k or --ask-pass] # if SSH password should be specified
        [-K or --ask-become-pass] # if "sudo" password should be specified
        [--key-file /root/.ssh/key] # if SSH private key should be specified
```

<!-- Links -->
[Bootstrap]: bootstrap.md
