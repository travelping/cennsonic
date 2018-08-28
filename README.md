# NFV K8s

Set of tools and guides for [NFV] enabled [Kubernetes] cluster setup and
operations.

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
is named "nfv-k8s.example.net" then for a single host setup use:

```
single.nfv-k8s.example.net
```

for a multi-host setup use:

```
master-[01:XX].nfv-k8s.example.net
worker-[01:XX].nfv-k8s.example.net
```

See also:

* [Setup Infrastructure on vSphere →] **WiP**
* [Setup Infrastructure with DRP →] **WiP**
* [Setup Infrastructure on AWS →] **WiP**
* [Setup Infrastructure on GCE →] **WiP**
* [Setup Infrastructure on IBM →] **WiP**

### Configuration

Let's name our cluster "nfv-k8s.example.net" (any other name can be used)
and get its initial configuration:

```
$ CLUSTER=nfv-k8s.example.net
$ mkdir $CLUSTER
$ docker run \
        --rm -v $PWD/$CLUSTER:/$CLUSTER \
        travelping/nfv-k8s cp -r /cluster /$CLUSTER
```

that should end up with the following structure:

```
$ tree $CLUSTER
nfv-k8s.example.net
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

   - cluster_name — use your name if differs from "nfv-k8s.example.net"

   - supplementary_addresses\_in\_ssl\_keys — if the "ip" variables in the
     "hosts.ini" file are set to IP addresses non-reachable from the outside,
     this option should be set to a list of the master nodes IP addresses
     reachable from the outside

 * all.yml — defines settings for all the hosts in the cluster. Some useful are:

   - ssh_users — list of users SSH keys to provision

   - http(s)_proxy — specify if the nodes access the Internet via proxy only

Makes sense to keep this configuration under version control if you plan to
evolve this cluster. Well, also makes sense if you do not plan that.

See also:

* [Turn Swap Off →] **WiP**
* [Provision SSH Keys →] **WiP**
* [Disable Sudo Password →] **WiP**

### Deploy

Once configuration is ready, plain Kubernetes cluster can be deployed:

```
$ docker run \
        --rm -it -v $PWD/$CLUSTER/config:/cluster/config \
        travelping/nfv-k8s ansible-playbook cluster.yml etcd-certs-symlinks.yml \
        -vbi /cluster/config/hosts.ini
        [-k or --ask-pass] # if SSH password should be specified
        [-K or --ask-become-pass] # if "sudo" password should be specified
        [--key-file ~/.ssh/id_rsa] # if SSH private key should be specified
```

If the deployment process succeeded the newly created cluster kubeconfig could
be merged into the main kubeconfig file:

```
$ KUBECONFIG=$CLUSTER/config/artifacts/admin.conf:~/.kube/config \
  kubectl config view --flatten > config
$ cp ~/.kube/config ~/.kube/config.bkp # backup config if feel unsafe
$ mv config ~/.kube/config
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
* [Certificates Manager →] **WiP**

## Troubleshooting and FAQ

We will try to keep here known issues and the ways of it resolving.

* [Exec Format Error →]

<!-- Links -->

[NFV]: https://en.wikipedia.org/wiki/Network_function_virtualization
[Docker]: https://docs.docker.com
[Docker image]: Dockerfile
[kubectl]: https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl
[Kubespray]: https://github.com/kubernetes-incubator/kubespray
[Kubernetes]: https://kubernetes.io
[Ubuntu 16.04 LTS]: http://releases.ubuntu.com/16.04

[Kubespray in Docker →]: docs/kubespray_in_docker.md

[Setup Infrastructure on vSphere →]: docs/vSphere.md
[Setup Infrastructure with DRP →]: docs/DRP.md
[Setup Infrastructure on IBM →]: docs/IBM.md
[Setup Infrastructure on AWS →]: docs/AWS.md
[Setup Infrastructure on GCE →]: docs/GCE.md

[Provision SSH Keys →]: docs/SSH_keys.md
[Turn Swap Off →]: docs/turn_swap_off.md
[Disable Sudo Password →]: docs/disable_sudo_password.md

[Users and Roles →]: docs/users_and_roles.md
[Scaling a Cluster →]: docs/scaling.md
[Upgrading a Cluster →]: docs/upgrade.md
[OS Kernel and Security Updates →]: docs/OS_update.md
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
