# Kube

[![License: Apache-2.0][Apache 2.0 Badge]][Apache 2.0]
[![GitHub Release Badge]][GitHub Releases]
[![Kubernetes Releases Badge]][Kubernetes Releases]

A [Kubeadm] based automation for deploying and operating [Cennsonic] core
components. The core components include vanilla [Kubernetes] cluster with the
following add-ons:

* [Calico]
* [CNI Node]
* [Kubealived]
* [Kube VXLAN Controller]

Contents:

* [Prerequisites](#prerequisites)
  * [Install Kube](#install-kube)
* [Setup](#setup)
  * [Prepare](#prepare)
  * [Download](#download)
  * [Install](#install)
    * [Node IP](#node-ip)
    * [API IP](#api-ip)
    * [Master Init](#master-init)
    * [Create User](#create-user)
    * [Single Node](#single-node)
    * [Master Join](#master-join)
    * [Worker Join](#worker-join)
    * [Setup Troubleshooting](#setup-troubleshooting)
* [License](#license)

## Prerequisites

Kube supports the following operating systems (in the preference order):

* [CoreOS Container Linux]
* [Ubuntu 18.04]
* [CentOS 7]

Fully qualified domain name should be both output of the "hostname" command and
content of the "/etc/hostname" file. For example if you setup a host named
"master-01.example.org" this should be the value. Especially on Ubuntu it is
often the case when the value is just "master-01", then it should be fixed.

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

## Setup

The cluster setup consists of two stages: "download" and "install". Depending
on the operating system additional preparation might be required (see below).

### Prepare

If your cluster hosts run CoreOS you can skip this step. In case of Ubuntu or
CentOS run the corresponding preparation against each one:

```
$ kube tools-<ubuntu|centos> <Host SSH> install [Username]
```

For example with an Ubuntu machine:

```
$ kube tools-ubuntu root@192.168.10.11 install ubuntu
```

The specified username ("ubuntu" in this case) will be created on the host if
does not exist. This user will later be used to install the cluster components
from (to avoid doing it from root). If you have an existing preferable user on
the machine, for example "vagrant" specify it.

The are known issues with "admin" user, so it should be avoided.

### Download

The download stage installs required binaries, [Docker] images and initial
manifests to run Cennsonic core components. The master and worker node
components are a bit different therefore we specify type of a node during
download:

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

### Install

Before installation it is better to get familiar with the IP addresses terms
used.

#### Node IP

The "Node IP" is an IP address to be used by internal Kubernetes components like
etcd or Calico related BGP services. Therefore it is always safer to use
a private network IP address. Although a public IP address can be used as well.
In this case you should understand the mentioned services internal ports will be
reachable from the outside which is a potential security breach.

#### API IP

The "API IP" is a Kubernetes API address. If you have a separate load balancer
for the master nodes then its IP should be specified. If you wish to use VRRP
with [Keepalived] you specify the VRRP IP. In this case you should also specify
the VRRP interface. If you do not have anything, specify one of the existing
master nodes IP (the "Node IP" in case of the very first master).

#### Master Init

Note the [Prepare] and [Download] steps.

The installation always starts with the first master node init and then the
other master or worker nodes are getting joined the cluster using the available
master node(s).

To init the first master:

```
$ kube node <Node SSH> master init <Node IP> <API IP> [VRRP Interface]
```

Example:

```
$ kube node core@192.168.10.11 master init 172.18.10.11 172.18.10.11
```

To install Keepalived (as Kubealived) and use 172.18.1.10 as VRRP IP:

```
$ kube node core@192.168.10.11 master init 172.18.10.11 172.18.1.10 eth0
```

Make sure to specify correct network interface for VRRP.

#### Create User

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

This will generate jsmith.conf kubeconfig file and create a cluster-admin
[ClusterRoleBinding] of this User name. The kubeconfig now can be copied over
from the master node:

```
$ scp core@192.168.10.11:jsmith.conf .
$ ssh core@192.168.10.11 rm jsmith.conf
```

To see more options:

```
$ kube user help
```

#### Single Node 

If you plan to use a single node cluster, you should assign your the only master
node a "worker" role:

```
$ kube node core@192.168.10.11 set role worker
```

Otherwise the workloads will not be scheduled due to the master nodes related
taints.

To unset the worker role:

```
$ kube node core@192.168.10.11 unset role worker
```

#### Master Join

Note the [Prepare] and [Download] steps.

To join another master node you should copy the PKI related files from the
existing one:

```
$ kube-pki <Host1 SSH> <Host2 SSH>
```

Example:

```
$ kube-pki core@192.168.10.11 core@192.168.10.12
```

When the PKI is ready the node can be joined:

```
$ kube node <Host SSH> master join <Node IP> <API IP>
```

Example:

```
$ kube node core@192.168.10.12 master join 172.18.10.12 172.18.10.11
```

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

#### Setup Troubleshooting

If anything goes wrong with a particular node during the installation process
and you are not really not sure what happened. You can always wipe out it with
"reset" command:

```
$ kube node <Host SSH> reset
```

This will cancel the "init" or "join" actions (including the "PKI step" on
master join) only and will not erase any downloaded binaries or images.

## License

Copyright 2018-2019 Travelping GmbH

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

<!-- Links -->

[Docker]: https://docs.docker.com
[Kubeadm]: https://kubernetes.io/docs/setup/independent/high-availability
[Cennsonic]: https://github.com/travelping/cennsonic
[Kubernetes]: https://kubernetes.io
[Keepalived]: http://keepalived.org
[ClusterRoleBinding]: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding

[CNI Node]: https://github.com/openvnf/cni-node
[Calico]: https://docs.projectcalico.org/v3.5/introduction
[Kubealived]: https://github.com/openvnf/kubealived
[Kube VXLAN Controller]: https://github.com/openvnf/kube-vxlan-controller

[CoreOS Container Linux]: https://coreos.com/os/docs/latest
[Ubuntu 18.04]: https://ubuntu.com
[CentOS 7]: https://centos.org
[SSH Config]: https://www.ssh.com/ssh/config

[Prepare]: #prepare
[Download]: #download

<!-- Badges -->

[Apache 2.0]: https://opensource.org/licenses/Apache-2.0
[Apache 2.0 Badge]: https://img.shields.io/badge/License-Apache%202.0-yellowgreen.svg?style=flat-square
[GitHub Releases]: https://github.com/travelping/cennsonic/releases
[GitHub Release Badge]: https://img.shields.io/github/release/travelping/cennsonic/all.svg?style=flat-square
[Kubernetes Releases]: https://github.com/kubernetes/kubernetes/releases
[Kubernetes Releases Badge]: https://img.shields.io/badge/Kubernetes-1.12.x-306CE6.svg?style=flat-square
