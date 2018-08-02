# Load Balancer

In case of Kubernetes cluster installation where cloud provided load balancer
is not available (for example on bare metal) or cannot be used for any reason,
there is an option to use [MetalLB]. It also enables an ability to create
Kubernetes services of type "LoadBalancer".

## Installation

The balancer could be installed this way:

```
$ kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.6.2/manifests/metallb.yaml
```

After installation it should be provided with [Layer2 configuration] describing
range of IP addresses available for allocation. We use the [MetalLB
configuration manifest] to create the corresponding configmap:

```
$ kubectl create -f https://gitlab.tpip.net/aalferov/nfv-k8s/raw/master/cluster/components/loadbalancer/metallb-config.yaml?private_token=$PRIVATE_TOKEN
```

## Usage example

As an example we deploy a service that depends on both TCP and UDP protocols.
[Iperf3], when running as a server can serve UDP traffic, but to negotiate with
Iperf3 client they use TCP. This creates a requirement of both protocols
availability on the same IP address.

First, we deploy the Iperf3 server:

```
$ kubectl run iperf3-server --image=aialferov/nettools --command -- iperf3 -s
```

In the [Example manifest] we describe two load balancers with use of the
[MetalLB IP address sharing] feature to serve both TCP and UDP traffic on the
same IP address. To create:

```
$ kubectl create -f https://gitlab.tpip.net/aalferov/nfv-k8s/raw/master/cluster/components/loadbalancer/example.yaml?private_token=$PRIVATE_TOKEN
```

Iperf3 client is needed to verify the server works as expected. Please refer the
[Iperf3 download] webpage to get its binary for your OS.

Now you can get the IP address of the service:

```
$ IP=$(kubectl get svc iperf3-server-tcp -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

And send UDP traffic (with implicit TCP negotiation) to it:

```
$ iperf3 -uc $IP
Connecting to host 192.168.96.70, port 5201
[  5] local 192.168.96.200 port 56054 connected to 192.168.96.70 port 5201
[ ID] Interval           Transfer     Bitrate         Total Datagrams
[  5]   0.00-1.00   sec   129 KBytes  1.06 Mbits/sec  101
[  5]   1.00-2.00   sec   128 KBytes  1.05 Mbits/sec  100
[  5]   2.00-3.00   sec   128 KBytes  1.05 Mbits/sec  100
```

Although we use the "-u" key of Iperf3 for sending UDP traffic, as mentioned, it
uses TCP for negotiation. To make sure it will not work without TCP, let's
delete the TCP load balancer:

```
$ kubectl delete svc iperf3-server-tcp
```

Although the UDP balancer is still there, it does not work:

```
$ iperf3 -uc $IP
iperf3: error - unable to connect to server: Network is unreachable
```

<!-- Links -->

[MetalLB]: https://metallb.universe.tf
[Iperf3]: https://iperf.fr
[Iperf3 download]: https://iperf.fr/iperf-download.php
[Example manifest]: ../../cluster/components/loadbalancer/example.yaml
[Layer2 configuration]: https://metallb.universe.tf/configuration/#layer-2-configuration
[MetalLB configuration manifest]: ../../cluster/components/loadbalancer/metallb-config.yaml
[MetalLB IP address sharing]: https://metallb.universe.tf/usage/#ip-address-sharing
