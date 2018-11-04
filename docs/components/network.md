# Network

To fullfil network requirements we install Multus and Kube VXLAN Controller.

## Multus

The default network operations between the pods are done using the [Calico]
managed network interfaces. Some cases require different ways of network
management one of which is satisfied with [Macvlan] networks.

[Multus] is used to delegate pod network management to both Calico and
optionally Macvlan or other [CNI-plugings]. To add further CNIs to a pod, a
respective annotation is used.

### Installation

The current installation process requires configuration first. Please follow
the section below.

### Configuration

Download sample Multus configuration file:

```
$ cd <Cluster Root Path>
$ mkdir -p components/network
$ curl https://raw.githubusercontent.com/travelping/cennsonic/master/components/network/multus-cni-configmap.yaml >> components/network/multus-cni-configmap.yaml
```

Replace "ETCD_ENDPOINTS" with the output of this command (gets current cluster
etcd endpoints):

```
$ kubectl -n kube-system get po -l k8s-app=kube-apiserver -o jsonpath='{.items[0].spec.containers[?(@.name=="kube-apiserver")].command[3]}' | cut -d= -f2
```

Create the configuration:

```
$ kubectl create -f components/network/multus-cni-configmap.yaml
```

Create the CRD for `NetworkAttachmentDefinition` used for defining additional
CNIs as well as the ClusterRole required for Multus:

```
$ kubectl create -f https://raw.githubusercontent.com/travelping/cennsonic/master/components/network/multus-crd.yaml
$ kubectl create -f https://raw.githubusercontent.com/travelping/cennsonic/master/components/network/multus-clusterrole.yaml
```

Download sample configuration for an additional CNI (Macvlan):

```
$ curl https://raw.githubusercontent.com/travelping/cennsonic/master/components/network/macvlan-net-attach-def.yaml >> components/network/macvlan-net-attach-def.yaml
```

Modify Macvlan interfaces according to your needs. Make sure you specified
a master device name of the interface that available on the nodes.

### Now Installation

After the configuration is in place, install Multus CNI itself:

```
$ kubectl create -f https://raw.githubusercontent.com/travelping/cennsonic/master/components/network/multus-cni-daemonset.yaml
```

*The following manual step should be simplified somewhow:*

You will then create a `clusterrolebinding` for each hostname in the
Kubernetes cluster. Replace `HOSTNAME` below with the host name of a node, and
then repeat for all hostnames in the cluster.

```
kubectl create clusterrolebinding multus-node-HOSTNAME \
    --clusterrole=multus-crd-overpowered \
    --user=system:node:HOSTNAME
```

### Usage

In order to create additional network interfaces based on the configured CNIs
in a pod, use an annotation like:

```
      annotations:
        k8s.v1.cni.cncf.io/networks: '[
            { "name": "macvlan-network",
              "interfaceRequest": "ext0" }
          ]'
```

To validate installation create a pod with the given annotation and verify it contains network
interfaces with the specified name or "net[0-N]" if no name is given.

To make any changes, apply the changed configuration file:

```
$ kubectl apply -f components/network/macvlan-net-attach-def.yaml
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

The controller could be installed this way:

```
$ kubectl create -f https://raw.githubusercontent.com/travelping/cennsonic/master/components/network/kube-vxlan-controller.yaml
```

### Configuration

After installation it could be provided with custom set of VXLAN networks that
suppose to be used by the pods. Copy the [VXLAN Network Configuration] sample
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
[Multus]: https://github.com/intel/multus-cni
[Macvlan]: https://docs.docker.com/network/macvlan
[Kube VXLAN Controller]: http://github.com/openvnf/kube-vxlan-controller
[CNI-plugins]: https://github.com/containernetworking/plugins

[VXLAN Network Configuration]: ../../components/network/kube-vxlan-controller.yaml#L20-29
