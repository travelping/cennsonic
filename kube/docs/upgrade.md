# Upgrade

Technically a cluster can be upgraded from v1.12.x to v1.13.x and then further
to v1.14.x. But at the moment master node add/delete operations are supported
for the v1.12.x branch only. Therefore currently upgrade is recommended within
this branch.

## Preparation

Edit the "apiEndpoints" section of the "kubeadm-config" ConfigMap to add an
entry for each of the additional master nodes:

```
$ kubectl -n kube-system edit cm kubeadm-config
```

For example if the section looks like this:

```
apiEndpoints:
  master-01.example.org:
    advertiseAddress: 172.18.10.11
    bindPort: 6443
```

but there are three master nodes actually, then the section should be extended:

```
apiEndpoints:
  master-01.example.org:
    advertiseAddress: 172.18.10.11
    bindPort: 6443
  master-02.example.org:
    advertiseAddress: 172.18.10.12
    bindPort: 6443
  master-03.example.org:
    advertiseAddress: 172.18.10.13
    bindPort: 6443
```

**Note:** if you upgrade to v1.13.x or v1.14.x, remove the "etcd" section
completely.

## Master Upgrade

On each master node:

* [download] the master node components of the desired version
* perform the upgrade operation:

  ```
  $ kube node <Host SSH> master upgrade
  ```

* wait for the node related Kubernetes core components pods are restarted before
  proceeding with the next node. The pods are:
  
  - API server
  - scheduler
  - controller manager
  - kube-proxy (usually get restarted after the first master upgrade only).

## Worker Upgrade

On each worker node:

* [download] the worker node components of the desired version
* restart Kubelet on each worker node:

  ```
  $ kube node <Host SSH> restart
  ```

<!-- Links -->

[download]: setup.md#download
