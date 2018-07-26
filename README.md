# NFV K8s

Set of tools and guides for [NFV] enabled [Kubernetes] cluster setup and
operations.

## Setup

The NFV cluster is based on a regular Kubernetes cluster so we start from
setting it up. For the setup we use [Kubespray] packed into a [Docker image],
so [Docker] is required. Also [kubectl] is required for cluster operations.

See also:

- TODO: [Kubespray in Docker →]

### Prerequisites

The current approach assumes that every host purposed for the cluster satisfies
the following conditioins:

- [Ubuntu 16.04 LTS] upgraded after the OS setup
- swap is turned off
- hostname is set to the corresponding node name
- SSH access

Optinally, sudo password could be disabled and needed SSH keys provisioned.

See also:

- TODO: [vSphere infrastructure provisioning →]
- TODO: [IBM infrastructure provisioning →]
- TODO: [AWS infrastructure provisioning →]

### Configuration

Name our cluster "nfv-k8s.example.net" (any other name can be used) and make its
initial configuration:

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
└── cluster
    └── config
        ├── group_vars
        │   ├── all.yml
        │   └── k8s-cluster.yml
        └── hosts.ini

3 directories, 3 files
```

The cluster topology is defined in the "hosts.ini" file and should be modified
as needed. Also pay attention to the SSH settings.

The "k8s-cluster.yml" defines Kubernetes settings, especially important might
be the following:

- kube_version — Kubernetes version
- cluster_name — "nfv-k8s.example.net" should be changed to the selected name
- supplementary_addresses\_in\_ssl\_keys — if the "ip" variable in the
"hosts.ini" file was set to the IP addresses non-reachable from the outside,
this options should have a list of the master nodes IP addresses reachable
from the outside.

The "all.yml" file should not be changed in most of the cases, but if the nodes
access the Internet via proxy only, it should be specified by defining
"http_proxy" and "https_proxy" options.

### Deploy

Once configuration is ready, plain Kubernetes cluster can be deployed:

```
$ docker run \
        --rm -v $PWD/$CLUSTER/cluster/config:/$CLUSTER/config \
        travelping/nfv-k8s ansible-playbook cluster.yml \
        -b -v -i /$CLUSTER/config/hosts.ini
        [-k or --ask-pass] # if SSH password should be specified
        [-K or --ask-become-pass] # if "sudo" password should be specified
        [--key-file ~/.ssh/id_rsa] # if SSH private key should be specified
```

If the deployment process succeeded the newly created cluster kubeconfig could
be merged into the main kubeconfig file:

```
$ KUBECONFIG=$CLUSTER/cluster/config/artifacts/admin.conf:~/.kube/config \
  kubectl config view --flatten > config
$ mv config ~/.kube/config
```

Check the nodes and pods list to make sure API is accessible and the cluster is
functional:

```
$ kubectl get nodes
$ kubectl get pods --all-namespaces
```

See also:

- TODO: [Cluster scaling →]
- TODO: [Cluster upgrade →]
- TODO: [OS Kernel and security updates →]

### Components

After the plain Kubernetes cluster is set up, additional components could be
installed to fulfill application and operational needs.

- TODO: [Storage →](docs/storage.md)
- TODO: [Network →](docs/network.md)
- TODO: [Load Balancer →](docs/loadbalancer.md)
- TODO: [Dashboard →](docs/dashboard.md)
- TODO: [Helm →](docs/helm.md)
- TODO: [Monitoring →](docs/monitoring.md)

<!-- Links -->

[NFV]: https://en.wikipedia.org/wiki/Network_function_virtualization
[Docker]: https://docs.docker.com
[Docker image]: Dockerfile
[kubectl]: https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl
[Kubespray]: https://github.com/kubernetes-incubator/kubespray
[Kubernetes]: https://kubernetes.io
[Ubuntu 16.04 LTS]: http://releases.ubuntu.com/16.04

[Kubespray in Docker →]: docs/kubespray_in_docker.md
[vSphere infrastructure provisioning →]: docs/vSphere.md
[IBM infrastructure provisioning →]: docs/IBM.md
[AWS infrastructure provisioning →]: docs/AWS.md
[Cluster scaling →]: docs/scaling.md
[Cluster upgrade →]: docs/upgrade.md
[OS Kernel and security updates →]: docs/OS_update.md
