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

To access any ingress controlled services the controller itself should be
exposed as a service. We expose it as load balancer service, therefore please
make sure the [Load Balancer] is installed.

Expose:

```
$ kubectl create -f https://raw.githubusercontent.com/travelping/cennsonic/master/components/ingress/ingress-service.yaml
```

<!-- Links -->

[Ingress]: https://kubernetes.io/docs/concepts/services-networking/ingress
[Load Balancer]: loadbalancer.md
