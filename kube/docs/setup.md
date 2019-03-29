# Setup

The setup process assumes the nodes are provisioned with a supported operating
system and consists of two stages: "Download" and "Install". Depending on the
operating system additional preparation might be required (described below).

* [Prerequisites](#prerequisites)
  * [Install Kube](#install-kube)
* [Prepare](#prepare)
* [Download](#download)
* [Install](#install)
  * [Node IP](#node-ip)
  * [API IP](#api-ip)
  * [Control Plane](#control-plane)
    * [Master Init](#master-init)
    * [Single Node](#single-node)
    * [Master Join](#master-join)
    * [Master Delete](#master-delete)
  * [Data Plane](#data-plane)
    * [Worker Join](#worker-join)
    * [Worker Delete](#worker-delete)
  * [Cluster Access](#cluster-access)
  * [Node Reset](#node-reset)

## Prerequisites

Kube supports the following operating systems (in the preference order):

* [CoreOS Container Linux]
* [Ubuntu 18.04]
* [CentOS 7]

Each host name should consist of two parts: node name and cluster name. The
cluster name should be the same on all nodes whereas the node names should
be different. If a cluster is named "cluster.example.org" and there are nodes
"master-01" and "worker-01", then the hosts should be named:

* master-01.cluster.example.org
* worker-01.cluster.example.org

Fully qualified domain name should be both output of the "hostname" command and
content of the "/etc/hostname" file. For example if you setup a host named
"master-01.cluster.example.org" this should be the value. Especially on Ubuntu
it is often the case when the value is just "master-01". Should be fixed then.

The hosts should be accessibe via SSH. The SSH port should either be default
(22) or configured in [SSH Config] file as there will be no way to specify a
custom port.

The hosts should be reachable from each other the full mesh. Better with a
private network.

### Install Kube

Kube is currently a set of scripts. They are to be run from a machine
controlling the installation and operation processes. For example your working
machine or a CI/CD worker. To install the scripts:

```
$ git clone https://github.com/travelping/cennsonic
$ make -C cennsonic/kube install # work in progress
```

If you prefer to avoid installing the scripts into the system, you can cd into
the "cennsonic/kube/src" folder and run from there.

## Prepare

If your cluster hosts run CoreOS you can skip this step. In case of Ubuntu or
CentOS run the corresponding preparation against each one:

```
$ kube tools-<ubuntu|centos> <Host SSH> install [Username]
```

For example with an Ubuntu machine:

```
$ kube tools-ubuntu root@192.168.10.11 install ubuntu
```

The specified user ("ubuntu" in this case) will be created on the host if does
not exist. This user will later be used to install the cluster components from
(to avoid doing it from root). If you have an existing preferable user on the
machine, for example "vagrant" specify it.

The are known issues with "admin" user, so better to avoid.

## Download

The download stage installs required binaries, [Docker] images and initial
manifests to run Cennsonic core components. The master and worker node
components are different therefore we specify type of a node during download:

```
$ kube tools <Host SSH> install <master|worker> <Kubernetes Version>
```

For example with a master and another worker machine:

```
$ kube tools core@192.168.10.11 install master v1.12.7
$ kube tools core@192.168.10.21 install worker v1.12.7
```

**Note:** you can download any version of Kubernetes, but further operations are
fully supported with the v1.12.x branch only.

## Install

Before installation it is better to get familiar with IP addresses terms used.

### Node IP

The "Node IP" is an IP address to be used by internal Kubernetes components like
etcd or Calico related BGP services. Therefore it is always safer to use
a private network IP address. Although a public IP address can be used as well.
In this case you should understand the mentioned services internal ports will be
reachable from the outside which is a potential security breach.

### API IP

The "API IP" is a Kubernetes API address. If you have a separate load balancer
for the master nodes then its IP should be specified. If you wish to use VRRP
with [Keepalived] you specify the VRRP IP. In this case you should also specify
the VRRP interface. If you do not have anything, specify one of the existing
master nodes IP (the "Node IP" in case of the very first master).

### Control Plane

The installation always starts with the control plane or master nodes. We init
the first master node and then the other nodes can join the cluster. The nodes
always join a cluster using the available master node(s).

#### Master Init

Note the [Prepare] and [Download] steps.

To init the first master:

```
$ kube node <Node SSH> master init <Node IP> <API IP> [VRRP Interface]
```

Example:

```
$ kube node core@192.168.10.11 master init 172.18.10.11 172.18.10.11
```

To install control plane with Keepalived (as [Kubealived]) for HA and use
172.18.1.10 as a VRRP IP, the first master should be initialized slightly
differently:

```
$ kube node core@192.168.10.11 master init 172.18.10.11 172.18.1.10 eth0
```

Make sure to specify correct network interface for VRRP.

See also:

* [Cluster Access]
* [Data Plane]

#### Single Node

If you plan to use a single node cluster, you should assign your the only master
node a "worker" role:

```
$ kube node core@192.168.10.11 role set worker
```

Otherwise the workloads will not be scheduled due to the master nodes related
taints.

If you changed your mind and plan to join workers to the single node cluster you
can get the hybrid node back to be master only:

```
$ kube node core@192.168.10.11 role unset worker
```

#### Master Join

Note the [Prepare] and [Download] steps.

To join another master node you should copy the PKI related files from the
existing one:

```
$ kube pki <Host1 SSH> <Host2 SSH>
```

Example:

```
$ kube pki core@192.168.10.11 core@192.168.10.12
```

When the PKI is ready the node can be joined:

```
$ kube node <Host SSH> master join <Node IP> <API IP>
```

Example:

```
$ kube node core@192.168.10.12 master join 172.18.10.12 172.18.10.11
```

#### Master Delete

A master node can be deleted from itself or from another master node.
Consider an example with two master nodes involved where we want to delete
"master-03":

* master-02.cluster.example.com (ssh: core@192.168.10.12)
* master-03.cluster.example.com (ssh: core@192.168.10.13)

Deleting from itself can be performed when the node is available and its API
server is operational:

```
$ kube node core@192.168.10.13 master delete
```

The "from itself" delete also includes node reset.

Deleting from the other available master might be helpful when the being deleted
node or its API server is not available:

```
$ kube node core@192.168.10.12 master delete master-03
```

As node reset in this case is not performed it is recommended to do it if
possible (**double check you reset the correct node**):

```
$ kube node core@192.168.10.13 reset
```

### Data Plane

All operations with data plane nodes or worker nodes will require a [Control
Plane] node. This includes joining to and also deleting a worker node from a
cluster.

#### Worker Join

Note the [Prepare] and [Download] steps.

To join a worker node you need a "join information". It can be get from any of
the existing master nodes:

```
$ kube node <Host SSH> master join-info
```

For example it could be kept in a variable and used aftewards:

```
$ JI=$(kube node core@192.168.10.11 master join-info)
```

Now we can join a worker:

```
$ kube node <Host SSH> worker join <Node IP> <API IP> <Join Info>
```

Example:

```
$ kube node core@192.168.10.21 worker join 172.18.10.21 172.18.10.11 "$JI"
```

#### Worker Delete

A worker node is always deleted from an available master node. Consider an
example with a master and a worker nodes:

* master-01.cluster.example.org (ssh: core@192.168.10.11)
* worker-01.cluster.example.org (ssh: core@192.168.10.21)

To delete the worker:

```
$ kube node core@192.168.10.11 worker delete worker-01
```

Reset of the deleted worker node is recommended if possible (**double check you
reset the correct node**):

```
$ kube node core@192.168.10.21 reset
```

### Cluster Access

The cluster could be accessed from any of its master nodes directly using admin
kubeconfig:

```
$ ssh <Host SSH>
$ sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes
```

This kubeconfig could have been copied and used from anywhere, but revoking it
could be not trivial. To avoid using the general admin kubeconfig we can create
a personalized one using an existing master node:

```
$ kube user <Host SSH> create <Username> --admin
```

Example:

```
$ kube user core@192.168.10.11 create jsmith --admin
```

This will generate "jsmith.conf" kubeconfig file and bind this user to the
"cluster-admin" role with a [ClusterRoleBinding]. Without the "--admin" switch
the binding will not be made. The kubeconfig now can be copied over from the
master node:

```
$ scp core@192.168.10.11:jsmith.conf .
$ ssh core@192.168.10.11 rm jsmith.conf
```

To see more options:

```
$ kube user help
```

### Node Reset

If something went wrong with a particular node during the installation process
and you are not sure what happened and not willing to debug, you can start from
the beginning. The "reset" command wipes a node out:

```
$ kube node <Host SSH> reset
```

This will cancel the "init" or "join" actions (including the "PKI step" for
master join) but will not erase the [Download] and [Prepare] steps.

If a node has already joined a cluster it is recommended to delete it before
reset:

* [Master Delete]
* [Worker Delete]

<!-- Links -->

[CoreOS Container Linux]: https://coreos.com/os/docs/latest
[Ubuntu 18.04]: https://ubuntu.com
[CentOS 7]: https://centos.org
[SSH Config]: https://www.ssh.com/ssh/config

[Docker]: https://docs.docker.com
[Keepalived]: http://keepalived.org
[Kubealived]: https://github.com/openvnf/kubealived
[ClusterRoleBinding]: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding

[Prepare]: #prepare
[Download]: #download
[Install]: #install

[Cluster Access]: #cluster-access
[Control Plane]: #control-plane
[Data Plane]: #data-plane

[Master Delete]: #master-delete
[Worker Delete]: #worker-delete
