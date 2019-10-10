# Cennsonic

[![License: Apache-2.0][Apache 2.0 Badge]][Apache 2.0]
[![GitHub Release Badge]][GitHub Releases]
![Unstable Badge]

Cennso stands for Cloud ENabled Network Service Operations. Cennsonic is a
[Kubernetes] based Cennso Network Integration Cluster.

**Note**. The Kubespray-based to deployment of Cennsonic is obsolete and has
been removed from this repository. It is replaced with a [Kubeadm] based
automation way -- [Kube](#kubernetes-cluster).

Rather than providing another turn-key automation tool for setting up
Kubernetes clusters, this is meant to provide a framework, tools, and
documentation to setup a cluster to run Cennso network services. Common
tools are utilized to address the respective aspects of a cluster.

- [Cloud Infrastrucutre Management](#infrastructure) with [Terraform]
- [Configuration Mangement](#configuration-management) with [Ansible]
- [Kubernetes Cluster Management](#kubernetes-cluster) based on [kubeadm]
- [Supporting Cluster Components](#components) deployed with [kubectl] and [helm]
- [Troubleshooting and FAQ](#troubleshooting-and-faq)


### Infrastructure

The current approach assumes that every host purposed for the cluster should
satisfy the following conditioins:

* [Ubuntu 18.04 LTS] OS upgraded after setup
* swap is turned off
* SSH access (either by password or by key)
* the hostname is set according to the node name (see recommendation below).

Optionally, sudo password could be disabled and needed SSH keys provisioned.

The recommended way of naming nodes is the following, assuming your cluster
is named "cennsonic.example.net":

```
master-[01:XX].cennsonic.example.net
worker-[01:XX].cennsonic.example.net
```

Templates to mange infrastructure are available in the [`infra/`](infra/) folder and
currently comprises

- IBM
- packet.net
- vshpere


### Configuration Management

Ansible playbooks for different aspects of configuration are provided in
the [`ansible/`](ansible/) folder.

Required configurations:

* [Turn Swap Off →]
* [Provision SSH Keys →]
* [Disable Sudo Password →]


### Kubernetes Cluster

A [Kubeadm]-based tool `kube` is used to deploy and maintain the Kubernets
mangement layer, which is acutally a shell script that executes `kubeadm`
on the remote hosts and takes care of some specific settings.

* [Setup](docs/kube/setup.md)
* [Upgrade](docs/kube/upgrade.md)
* [Troubleshooting](docs/kube/troubleshooting.md)


### Components

After the plain Kubernetes cluster is set up, additional components could be
installed to fulfill application and operational needs.

* [Helm →]
* [Ingress →]
* [Network →]
* [Storage →]
* [Dashboard →]
* [Monitoring →] **NYI**
* [Load Balancer →]
* [Certificates Manager →] **WiP**


## Troubleshooting and FAQ

We will try to keep here known issues and the ways of it resolving.

* [Exec Format Error →]

## License

Copyright 2018 Travelping GmbH

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

[Kube]: kube
[Kubeadm]: https://kubernetes.io/docs/setup/independent/high-availability
[Apache 2.0]: https://opensource.org/licenses/Apache-2.0
[GitHub Releases]: https://github.com/travelping/cennsonic/releases
[NFV]: https://en.wikipedia.org/wiki/Network_function_virtualization
[Docker]: https://docs.docker.com
[Docker image]: Dockerfile
[kubectl]: https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl
[Kubespray]: https://github.com/kubernetes-incubator/kubespray
[Kubernetes]: https://kubernetes.io
[Cennsonic Tool]: bin/cennsonic
[Ubuntu 18.04 LTS]: http://releases.ubuntu.com/18.04

[Setup Infrastructure on Bare Metal →]: docs/infra/bare_metal.md
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

[Calico]: https://docs.projectcalico.org/v3.5/introduction
[Kubeadm]: https://kubernetes.io/docs/setup/independent/high-availability
[CNI Node]: https://github.com/openvnf/cni-node
[Cennsonic]: https://github.com/travelping/cennsonic
[Keepalived]: http://keepalived.org
[Kubealived]: https://github.com/openvnf/kubealived
[Kubernetes]: https://kubernetes.io
[Calico Sync]: https://github.com/openvnf/calico-sync
[Kube VXLAN Controller]: https://github.com/openvnf/kube-vxlan-controller

<!-- Badges -->

[Apache 2.0 Badge]: https://img.shields.io/badge/License-Apache%202.0-yellowgreen.svg?style=flat-square
[Unstable Badge]: https://img.shields.io/badge/state-unstable-red.svg?style=flat-square
[GitHub Release Badge]: https://img.shields.io/github/release/travelping/cennsonic/all.svg?style=flat-square
