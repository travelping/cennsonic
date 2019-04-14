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
* [Calico Sync]
* [Kube VXLAN Controller]

## Contents

* [Setup]
* [Upgrade]
* [Troubleshooting]

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

[Calico]: https://docs.projectcalico.org/v3.5/introduction
[Kubeadm]: https://kubernetes.io/docs/setup/independent/high-availability
[CNI Node]: https://github.com/openvnf/cni-node
[Cennsonic]: https://github.com/travelping/cennsonic
[Keepalived]: http://keepalived.org
[Kubealived]: https://github.com/openvnf/kubealived
[Kubernetes]: https://kubernetes.io
[Calico Sync]: https://github.com/openvnf/calico-sync
[Kube VXLAN Controller]: https://github.com/openvnf/kube-vxlan-controller

[Setup]: docs/setup.md
[Upgrade]: docs/upgrade.md
[Troubleshooting]: docs/troubleshooting.md

<!-- Badges -->

[Apache 2.0]: https://opensource.org/licenses/Apache-2.0
[Apache 2.0 Badge]: https://img.shields.io/badge/License-Apache%202.0-yellowgreen.svg?style=flat-square
[GitHub Releases]: https://github.com/travelping/cennsonic/releases
[GitHub Release Badge]: https://img.shields.io/github/release/travelping/cennsonic/all.svg?style=flat-square
[Kubernetes Releases]: https://github.com/kubernetes/kubernetes/releases
[Kubernetes Releases Badge]: https://img.shields.io/badge/Kubernetes-1.12.x%20to%201.14.x-306CE6.svg?style=flat-square
