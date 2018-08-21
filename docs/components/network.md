# Network

To fullfil network requirements we install Multus and Kube VXLAN Controller.

## Multus

**WiP**

The default network operations between the pods are done using the [Calico]
managed network interfaces. Some cases (some VNFs) require different ways of
network management one of which is satisfied with [Macvlan] networks.

[Multus] is used to have both types of network interfaces in the pods.

Install (requires [Private Token]):

```
$ kubectl create -f cluster/network/multus-cni-configmap.yaml
$ kubectl create -f cluster/network/multus-cni-daemonset.yaml
```

## Kube VXLAN controller

For some scenarios the easiest way to implement is using VXLAN overlay. [Kube
VXLAN Controller] helps to manage the corresponding VXLAN network interfaces in
the pods.

Install (requires [Private Token]):

```
$ kubectl create -f https://gitlab.tpip.net/aalferov/nfv-k8s/raw/master/cluster/components/network/kube-vxlan-controller.yaml?private_token=$PRIVATE_TOKEN
```

For the custom network configuration it is recommended to keep the [VXLAN
Network Configuration] manifest in your cluster repository with all the needed
network defined.

<!-- Links -->

[Calico]: https://www.projectcalico.org
[Multus]: https://github.com/intel/multus-cni
[Macvlan]: https://docs.docker.com/network/macvlan
[Kube VXLAN Controller]: http://github.com/openvnf/kube-vxlan-controller

[VXLAN Network Configuration]: ../../cluster/components/network/kube-vxlan-controller.yaml#L20-29

[Private Token]: ../gitlab_private_token.md
