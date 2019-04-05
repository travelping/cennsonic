# Troubleshooting

This page describes issues known to happen during installation or operations.

* [Calico](#calico)
  * [Calicoctl](#calicoctl)
  * [Calico Sync](#calico-sync)
* [Etcd](#etcd)
* [Multus CNI](#multus-cni)
* [Kubeliaved](#kubealived)

## Calico

If Calico pods have 0/1 running container this is a sign of a broken Calico
network. This could be due to some node(s) unavailability or incorrect CNI
configuration.

### Calicoctl

The [calicoctl] tool might help debug it. To install:

```
$ VERSION=$(kubectl -n kube-system get po \
                    -l k8s-app=calico-node \
                    -o jsonpath={.items[0].spec.containers[0].image} | \
            sed "s/.*://")
$ kube tools <Host SSH> install calicoctl $VERSION
```

The tool will be installed on the specified node. To check the network status:

```
$ ssh <Host SSH> sudo calicoctl node status
```

The BGP status should show all the connections established. Otherwise the broken
node should be either healed or removed from a cluster (see [Master Delete] and
[Worker Delete]).

Sometimes the status says it cannot connect to a node that was recently
explicitly removed. In this case restarting of all the "calico-node" pods most
likely helps:

```
$ kubectl -n kube-system delete po -l k8s-app=calico-node
```

### Calico Sync

[Calico Sync] is responsible for updating CNI configuration files of Calico
(the /etc/cni/net.d/10-calico.conflist file on each node) when the
"etcd_endpoints" field of the "kube-system/calico-config" ConfigMap is updated.
Usually that happens when a master node joins to or is removed from a cluster.
Therefore it is always worth to check if the etcd endpoints are configured
correctly. Checking the Calico Sync pods logs also might help.

## Etcd

The etcd cluster can be debugged with the [etcdctl] tool. An etcd node runs as
a pod on a corresponding master node, so the tool should be run from such a pod.
To get to an etcd pod's shell:

```
$ POD=$(kubectl -n kube-system get po \
                -l component=etcd \
                -o jsonpath={.items[0].metadata.name})
$ kubectl -n kube-system exec -it $POD sh
```

To get any information from etcdctl it should be provided with PKI information
and an endpoint:

```
$ etcdctl="etcdctl \
    --ca-file /etc/kubernetes/pki/etcd/ca.crt \
    --key-file /etc/kubernetes/pki/etcd/peer.key \
    --cert-file /etc/kubernetes/pki/etcd/peer.crt \
    --endpoint https://127.0.0.1:2379"
```

Now we can list the etcd members:

```
$ $etcdctl member list
```

If there is a failing etcd node it can be removed from an etcd cluster manually
if [Master Delete] failed to do that for any reason:

```
$ $etcdctl member remove <Member ID>
```

## Multus CNI

The Multus CNI (config file /etc/cni/net.d/05-multus-cni.conf) actually besides
delegating networking management to some side plugins like MACVLAN, first of all
delegates the main pod network to Calico. Therefore etcd endpoints in the Calico
delegation section of this config should be also actual. The "multus-cni-node"
pods are responsible for keeping that in sync, so checking their logs in case
of issues with Calico might also be helpful. This is usually actual for the
worker nodes only.

## Kubealived

Sometimes after deleting the last master node, the VRRP IP used is not wiped
out. If you have API access issues within a cluster or during the installation
it is worth to check if some recently used VRRP IP is assigned more than on one
node or assigned although should not be (yet).

<!-- Links -->

[calicoctl]: https://docs.projectcalico.org/v3.5/usage/calicoctl/install
[etcdctl]: https://coreos.com/etcd/docs/latest/dev-guide/interacting_v3.html

[Master Delete]: setup.md#master-delete
[Worker Delete]: setup.md#worker-delete
