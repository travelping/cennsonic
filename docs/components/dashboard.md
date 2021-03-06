# Dashboard

[Kubernetes Dashboard] is a general purpose, web-based UI for Kubernetes
clusters. It allows users to manage applications running in the cluster and
troubleshoot them, as well as manage the cluster itself.

## Setup

To install dashboard:

```
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
```

Dashboard is now installed with minimal privileges. That blocks it from
providing some information about the cluster.

We increase privileges of the service account used by the dashboard deployment
by binding it to the "cluster-admin" role. For that we use the [RBAC Dashboard]
manifest to create the corresponding binding:

```
$ kubectl create -f https://raw.githubusercontent.com/travelping/cennsonic/master/components/dashboard/dashboard-rbac.yaml
```

## Access

Afterwards it is possible to access the dashboard with help of Kubernetes proxy:

```
$ kubectl proxy
```

Now it is available at [Proxy URL].

It will require a token to authenticate, which could be extracted from the
corresponding account this way:

```
$ kubectl -n kube-system get secret -o jsonpath='{.items[?(@.metadata.annotations.kubernetes\.io\/service-account\.name=="kubernetes-dashboard")].data.token}' | base64 -D; echo
```

<!-- Links -->

[Proxy URL]: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy
[RBAC Dashboard]: ../../components/dashboard/dashboard-rbac.yaml
[Kubernetes Dashboard]: https://github.com/kubernetes/dashboard
