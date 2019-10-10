# Upgrade

At the moment clusters of the versions from v1.12.x to v1.14.x are supported.
If you upgrade within a major version, for example from v1.12.3 to v1.12.7, it
is fine to skip the intermediate versions. The major versions should be upgraded
one by one (i.e. v1.12.x → v1.13.x → v1.14.x).

## Preparation

If you upgrade from v1.12.x to v1.13.x, remove the "etcd" section from the
"kubeadm-config" ConfigMap completely. To edit the ConfigMap:

```
$ kubectl -n kube-system edit cm kubeadm-config
```

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
* restart Kubelet:

  ```
  $ kube node <Host SSH> restart
  ```

<!-- Links -->

[download]: setup.md#download
