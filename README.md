# Cennsonic

[![License: Apache-2.0][Apache 2.0 Badge]][Apache 2.0]
![Version Badge]
![Unstable Badge]

Cennso is cloud enabled network service operations. Cennsonic is a Cennso
network integration cluster.

Defines set of tools and guides for [NFV] enabled [Kubernetes] cluster setup and
operations.

* [Setup](#setup)
  * [Infrastructure](#infrastructure)
  * [Configuration](#configuration)
  * [Deploy](#deploy)
  * [Components](#components)
* [Troubleshooting and FAQ](#troubleshooting-and-faq)

## Setup

The NFV cluster is based on a regular Kubernetes cluster, so we start from
setting it up. For the setup we use [Kubespray] packed into a [Docker image],
so [Docker] is required. Also [kubectl] is required for cluster operations.

See also:

* [Kubespray in Docker →] **WiP**

### Infrastructure

The current approach assumes that every host purposed for the cluster should
satisfy the following conditioins:

* [Ubuntu 16.04 LTS] OS upgraded after setup
* swap is turned off
* SSH access (either by password or by key)
* the hostname is set according to the node name (see recommendation below).

Optionally, sudo password could be disabled and needed SSH keys provisioned.

The recommended way of naming nodes is the following. Assuming your cluster
is named "cennsonic.example.net" then for a single host setup use:

```
single.cennsonic.example.net
```

for a multi-host setup use:

```
master-[01:XX].cennsonic.example.net
worker-[01:XX].cennsonic.example.net
```

See also:

* [Setup Infrastructure on vSphere →] **WiP**
* [Setup Infrastructure on Packet →] **WiP**
* [Setup Infrastructure on AWS →] **WiP**
* [Setup Infrastructure on GCE →] **WiP**
* [Setup Infrastructure on IBM →] **WiP**

Requires [Configuration](#configuration):

* [Turn Swap Off →]
* [Provision SSH Keys →]
* [Disable Sudo Password →]

### Configuration

The [Cennsonic Tool] might be helpful to shorten some commands from this guide.
Download and install:

```
$ wget https://raw.githubusercontent.com/travelping/cennsonic/master/bin/cennsonic
$ install cennsonic /usr/local/bin/cennsonic
```

Let's name our cluster "cennsonic.example.net" (any other name can be used) and
get its initial configuration:

```
$ cennsonic init cennsonic.example.net
```

without "cennsonic":

```
$ CLUSTER=cennsonic.example.net
$ mkdir $CLUSTER
$ docker run \
        --rm -v $PWD/$CLUSTER:/$CLUSTER \
        travelping/cennsonic cp -r /cluster /$CLUSTER
```

that should end up with the following structure:

```
$ tree $CLUSTER
cennsonic.example.net
└── config
    ├── group_vars
    │   ├── all.yml
    │   └── k8s-cluster.yml
    └── hosts.ini

3 directories, 3 files
```

Let's have a look into the files:

 * hosts.ini — defines cluster topology and SSH access details. Modify according
   to your desired topology and SSH setting. Make sure your nodes hostnames are
   set according to the hostnames in this file

 * k8s-cluster.yml — defines Kubernetes settings, especially important might be
   the following:

   - kube_version — Kubernetes version

   - cluster_name — use your name if differs from "cennsonic.example.net"

   - supplementary_addresses\_in\_ssl\_keys — list of all the IP addresses and
     DNS names that might be used to access Kubernetes API of the cluster.
     Make sure to specify here list of IP addresses that you are going to use
     to access the Kubernetes API server

 * all.yml — defines settings for all the hosts in the cluster. During the
   deployment the useful might be "http(s)_proxy". Should be specified if the
   nodes access the Internet via proxy only.

Makes sense to keep this configuration under version control if you plan to
evolve this cluster. Well, also makes sense if you do not plan that.

### Deploy

Once the configuration is ready, a plain Kubernetes cluster can be deployed:

```
$ cd <Cluster Root Path>
$ cennsonic deploy
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
        travelping/cennsonic ansible-playbook deploy.yml \
        -vbi /cluster/config/hosts.ini
        [-k or --ask-pass] # if SSH password should be specified
        [-K or --ask-become-pass] # if "sudo" password should be specified
        [--key-file /root/.ssh/key] # if SSH private key should be specified
```

If the deployment process succeeded the newly created cluster kubeconfig could
be merged into the main kubeconfig file. The existing config will be changed
so backup it if feel unsafe:

```
$ cp ~/.kube/config ~/.kube/config.bkp
```

If you specified internal IP addresses for the nodes ("ip=") in the
"config/hosts.ini" file, one of them will be used in the generated kubeconfig
by default and therefore the cluster API will not be reachable from the outside.
Change the server address to one of the public ones before merging:

```
$ kubectl config set-cluster $(basename $(pwd)) --server=https://<Public IP>:6443 --kubeconfig=config/artifacts/admin.conf
```

Now you can merge the new config into the existing one:

```
$ KUBECONFIG=config/artifacts/admin.conf:~/.kube/config kubectl config view --flatten > config.new
$ mv config.new ~/.kube/config
```

It is not recommended to put this file under version control, therefore it
should be removed from the cluster file tree after merging into the main
kubeconfig file.

Check the nodes and pods list to make sure API is accessible and the cluster is
functional:

```
$ kubectl get nodes
$ kubectl get pods --all-namespaces
```

See also:

* [Users and Roles →] **WiP**
* [Scaling a Cluster →] **WiP**
* [Upgrading a Cluster →] **WiP**
* [OS Kernel and Security Updates →] **WiP**
* [Modifying Kubelet Start Arguments →] **WiP**
* [CIS Kubernetes Benchmark Compliance →] **WiP**
* [Modifying a Cluster API access addresses →] **WiP**

### Components

After the plain Kubernetes cluster is set up, additional components could be
installed to fulfill application and operational needs.

* [Helm →]
* [Ingress →]
* [Network →]
* [Storage →]
* [Dashboard →]
* [Monitoring →] **WiP**
* [Load Balancer →]
* [Certificates Manager →]

## Troubleshooting and FAQ

We will try to keep here known issues and the ways of it resolving.

* [Exec Format Error →]

<!-- Links -->

[Apache 2.0]: https://opensource.org/licenses/Apache-2.0
[NFV]: https://en.wikipedia.org/wiki/Network_function_virtualization
[Docker]: https://docs.docker.com
[Docker image]: Dockerfile
[kubectl]: https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl
[Kubespray]: https://github.com/kubernetes-incubator/kubespray
[Kubernetes]: https://kubernetes.io
[Cennsonic Tool]: bin/cennsonic
[Ubuntu 16.04 LTS]: http://releases.ubuntu.com/16.04

[Kubespray in Docker →]: docs/kubespray_in_docker.md

[Setup Infrastructure on vSphere →]: docs/infra/vsphere.md
[Setup Infrastructure on Packet →]: docs/infra/packet.md
[Setup Infrastructure on IBM →]: docs/infra/ibm.md
[Setup Infrastructure on AWS →]: docs/infra/aws.md
[Setup Infrastructure on GCE →]: docs/infra/gce.md

[Turn Swap Off →]: docs/infra/turn_swap_off.md
[Provision SSH Keys →]: docs/infra/ssh_keys.md
[Disable Sudo Password →]: docs/infra/disable_sudo_password.md

[Users and Roles →]: docs/users_and_roles.md
[Scaling a Cluster →]: docs/scaling.md
[Upgrading a Cluster →]: docs/upgrade.md
[OS Kernel and Security Updates →]: docs/os_update.md
[Modifying Kubelet Start Arguments →]: docs/kubelet.md
[CIS Kubernetes Benchmark Compliance →]: docs/cis_benchmark.md
[Modifying a Cluster API access addresses →]: docs/access_addresses.md

[Helm →]: docs/components/helm.md
[Ingress →]: docs/components/ingress.md
[Network →]: docs/components/network.md
[Storage →]: docs/components/storage.md
[Dashboard →]: docs/components/dashboard.md
[Monitoring →]: docs/components/monitoring.md
[Load Balancer →]: docs/components/loadbalancer.md
[Certificates Manager →]: docs/components/certmanager.md

[Exec Format Error →]: docs/troubleshooting/exec_format_error.md

<!-- Badges -->
[Apache 2.0 Badge]: https://img.shields.io/badge/License-Apache%202.0-yellowgreen.svg?style=flat-square
[Unstable Badge]: https://img.shields.io/badge/state-unstable-red.svg?style=flat-square
[Version Badge]: https://img.shields.io/badge/version-0.1.0-blue.svg?style=flat-square
