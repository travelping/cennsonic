# Network

To fullfil network requirements we install Multus and Kube VXLAN Controller.

## Multus

The default network operations between the pods are done using the [Calico]
managed network interfaces. Some cases (some VNFs) require different ways of
network management one of which is satisfied with [Macvlan] networks.

[Multus] is used to have both types of network interfaces in the pods.

### Installation

The current installation process requires configuration first. Please follow
the section below.

### Configuration

Download sample Multus configuration file (requires [Private Token]):

```
$ CLUSTER=<Cluster Root Path>
$ mkdir -p $CLUSTER/components/network
$ curl https://gitlab.tpip.net/aalferov/nfv-k8s/raw/master/components/network/multus-cni-configmap.yaml?private_token=$PRIVATE_TOKEN >> $CLUSTER/components/network/multus-cni-configmap.yaml
```

Replace "ETCD_ENDPOINTS" with the output of this command (gets current cluster
etcd endpoints):

```
$ kubectl -n kube-system get po -l k8s-app=kube-apiserver -o jsonpath='{.items[0].spec.containers[?(@.name=="kube-apiserver")].command[3]}' | cut -d= -f2
```

Modify Macvlan interfaces according to your needs. Make sure you specified
a master device name of the interface that available on the nodes.

Create the configuration:

```
$ kubectl create -f $CLUSTER/components/network/multus-cni-configmap.yaml
```

### Now Installation

After the configuration is in place, install Multus CNI itself
(requires [Private Token]):

```
$ kubectl create -f https://gitlab.tpip.net/aalferov/nfv-k8s/raw/master/components/network/multus-cni-daemonset.yaml?private_token=$PRIVATE_TOKEN
```

To validate installation create a pod and verify it contains network
interface(s) named "net[0-N]" and is/are assigned IP address(es) from the
specified subnet(s) and range(s).

To make any changes, apply the changed configuration file:

```
$ kubectl apply -f $CLUSTER/components/network/multus-cni-configmap.yaml
```

and restart the pods, for example this way:

```
$ kubectl -n kube-system delete pod -l app=multus-cni
```

## Kube VXLAN Controller

For some scenarios the easiest way to implement is using VXLAN overlay. [Kube
VXLAN Controller] helps to manage the corresponding VXLAN network interfaces in
the pods.

### Installation

The controller could be installed this way (requires [Private Token]):

```
$ kubectl create -f https://gitlab.tpip.net/aalferov/nfv-k8s/raw/master/components/network/kube-vxlan-controller.yaml?private_token=$PRIVATE_TOKEN
```

### Configuration

After installation it could be provided with custom set of VXLAN networks that
suppose to be used by the pods. Copy the [VXLAN Network Configuration] sample
manifest to your cluster location, for example (requires [Private Token]):

```
$ CLUSTER=<Cluster Root Path>
$ mkdir -p $CLUSTER/components/network
$ curl -s https://gitlab.tpip.net/aalferov/nfv-k8s/raw/master/components/network/kube-vxlan-controller.yaml?private_token=$PRIVATE_TOKEN | head -n29 | tail -n10 >> $CLUSTER/components/network/kube-vxlan-controller-networks.yaml
```

and change the network set according to your needs. When the change is ready,
apply the configuration:

```
$ kubectl apply -f $CLUSTER/components/network/kube-vxlan-controller-networks.yaml
```

<!-- Links -->

[Calico]: https://www.projectcalico.org
[Multus]: https://github.com/intel/multus-cni
[Macvlan]: https://docs.docker.com/network/macvlan
[Kube VXLAN Controller]: http://github.com/openvnf/kube-vxlan-controller

[VXLAN Network Configuration]: ../../components/network/kube-vxlan-controller.yaml#L20-29

[Private Token]: ../gitlab_private_token.md
