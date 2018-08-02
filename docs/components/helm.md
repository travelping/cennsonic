# Helm

Helm is a package manager for Kubernetes and can be used to install workloads in
a cluster.

## Installation

[Helm Client] is required to install Helm Server — [Tiller] into a cluster and
for any further Helm based operations.

For Helm to be able doing operations across the cluster we increase its
privileges by using the "cluster-admin" cluster role. For that we create
a service account and bind it to that role:

```
kubectl create -f https://gitlab.tpip.net/aalferov/nfv-k8s/blob/master/cluster/components/helm/rbac-tiller.yaml?private_token=$PRIVATE_TOKEN
```

After that we can install Helm in a way to use that service account:

```
helm init --service-account tiller
```

<!-- Links -->

[Helm]: https://helm.sh
[Tiller]: https://docs.helm.sh/using_helm/#installing-tiller
[Helm Client]: https://docs.helm.sh/using_helm/#installing-the-helm-client
