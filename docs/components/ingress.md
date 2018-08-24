# Ingress

[Ingress] manages external access to the services in a cluster, typically HTTP.
Ingress can provide load balancing, SSL termination and name-based virtual
hosting.

## Installation

First we install Ingress Controller, Default Backend and other necessary objects
(like Roles, Bindings, Namespace):

```
$ kubectl create -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml
```

Then we create a Load Balancer service to expose the Ingress Controller
deployment (requires [Private Token]):

```
$ kubectl create -f https://gitlab.tpip.net/aalferov/nfv-k8s/raw/master/components/ingress/ingress-service.yaml?private_token=$PRIVATE_TOKEN
```

<!-- Links -->

[Ingress]: https://kubernetes.io/docs/concepts/services-networking/ingress

[Private Token]: ../gitlab_private_token.md
