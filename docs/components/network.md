# Network

To fullfil network requirements for specific cases we install:

* [Multus CNI →]
* [Kube Vxlan Controller →]

## Multus CNI

The default network operations between the pods are done using the [Calico]
managed network interfaces. Some cases require different ways of network
management one of which is satisfied with [Macvlan] networks.

[Multus CNI] is used to delegate pod network management to both Calico and
optionally Macvlan or other [CNI Plugins]. To add further CNIs to a pod, a
respective annotation is used.

See also:

* [Bridge vs Macvlan →]
* [Macvlan vs Ipvlan →]

### Installation

We use [CNI Node] to install and configure additional CNIs and Multus or Macvlan
CNI in particular. CNI Node runs as a daemonset to install needed files on each
Kubernetes node and requires escalated privileges to deploy node specific
cluster role binding according to Multus requirements (see [Multus CNI Example]
for details).

First, we install objects from the [Multus CNI RBAC Manifest] for privileges,
and the main object and workloads from the [Multus CNI Manifest]:

```
$ kubectl apply -f https://raw.githubusercontent.com/travelping/cennsonic/master/components/network/multus-cni-rbac.yaml
$ kubectl apply -f https://raw.githubusercontent.com/travelping/cennsonic/master/components/network/multus-cni-ks.yaml
```

### Usage

After installation Multus delegates all the networking management to Calico. To
add another delegation, we create Network Attachment Definition or "nad". This
example creates an attachment for using Macvlan:

```
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: macvlan0
spec:
  config: '{
    "type": "macvlan",
    "master": "eth0", # use actual interface of the node
    "ipam": {
      "type": "host-local",
      "subnet": "172.16.10.0/24"
    }
  }'
```

Please make sure the actual master interface is used.

A "nad" is created per namespace. After it is created it can be used in the same
namespace only. To use the created attachment in a pod it have to be annotated:

```
metadata:
  annotations:
    k8s.v1.cni.cncf.io/networks: '[
      {"name": "macvlan0",
       "interfaceRequest": "macvi0"}
    ]'
```

This annotation refers to the attachment "macvlan0" (as in the "nad" example)
and requests interface name in the pod to be named "macvi0". If no interface
name specified the "net[0-N]" one will be given.

After the pod with this annotation is started it should contain an interface
with requested name and an IP address from the defined (in the "nad") subnet
assigned.

### CNI Plugins Set

Currently we install Multus CNI and Macvlan plugins only. The set of CNI plugins
can be changed by modifying and applying the [Multus CNI Manifest]. Please
review the "containers" section of the DaemonSet.

### Uninstallation

To uninstall everything that was installed, that includes deleting added by
installation files on the nodes, delete the "multus-cni" objects in reverse
order:

```
$ kubectl delete -f https://raw.githubusercontent.com/travelping/cennsonic/master/components/network/multus-cni-ks.yaml
$ kubectl delete -f https://raw.githubusercontent.com/travelping/cennsonic/master/components/network/multus-cni-rbac.yaml
```

## Kube Vxlan Controller

For some scenarios the easiest way to implement is using VXLAN overlay. [Kube
Vxlan Controller] helps to manage the corresponding VXLAN network interfaces in
the pods.

### Installation

Install controller from the [Kube Vxlan Controller Manifest]:

```
$ kubectl create -f https://raw.githubusercontent.com/travelping/cennsonic/master/components/network/kube-vxlan-controller.yaml
```

### Usage

Please refer the [Kube Vxlan Controller] documentation and
[Kube Vxlan Controller Usage Example].

### Configuration

After installation it could be provided with custom set of VXLAN networks that
suppose to be used by pods. Copy the [VXLAN Network Configuration] sample
manifest to your cluster location, for example:

```
$ cd <Cluster Root Path>
$ mkdir -p components/network
$ curl -s https://raw.githubusercontent.com/travelping/cennsonic/master/components/network/kube-vxlan-controller.yaml | head -n29 | tail -n10 >> components/network/kube-vxlan-controller-networks.yaml
```

and change the network set according to your needs. When the change is ready,
apply the configuration:

```
$ kubectl apply -f components/network/kube-vxlan-controller-networks.yaml
```

<!-- Links -->

[Calico]: https://www.projectcalico.org
[CNI Node]: https://github.com/openvnf/cni-node
[CNI Plugins]: https://github.com/containernetworking/plugins
[Kube Vxlan Controller Manifest]: ../../components/network/kube-vxlan-controller.yaml
[Multus CNI Manifest]: ../../components/network/multus-cni-ks.yaml
[Multus CNI RBAC Manifest]: ../../components/network/multus-cni-rbac.yaml
[Macvlan]: https://docs.docker.com/network/macvlan
[Multus CNI]: https://github.com/intel/multus-cni
[Multus CNI CRD]: https://github.com/intel/multus-cni#usage-with-kubernetes-crd-based-network-objects
[Multus CNI Example]: https://github.com/intel/multus-cni/tree/master/examples
[Kube VXLAN Controller]: http://github.com/openvnf/kube-vxlan-controller

[Bridge vs Macvlan →]: https://hicu.be/bridge-vs-macvlan
[Macvlan vs Ipvlan →]: https://hicu.be/macvlan-vs-ipvlan

[VXLAN Network Configuration]: ../../components/network/kube-vxlan-controller.yaml#L20-29

[Multus CNI →]: #multus-cni
[Kube VXLAN Controller →]: #kube-vxlan-controller
