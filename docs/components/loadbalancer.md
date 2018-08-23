# Load Balancer

In case of a Kubernetes cluster installation where cloud provided load balancer
is not available (for example on bare metal) or cannot be used for any reason,
there is an option to use [MetalLB]. It enables an ability to create Kubernetes
services of type [LoadBalancer].

## Installation

The balancer could be installed this way:

```
$ kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.7.3/manifests/metallb.yaml
```

## Configuration

After installation it should be provided with [Layer2 configuration] describing
range of IP addresses available for allocation. Copy the [MetalLB configuration
manifest] to your cluster location, for example (requires [Private Token]):

```
$ CLUSTER=<Cluster Root Path>
$ mkdir -p $CLUSTER/components/loadbalancer
$ curl https://gitlab.tpip.net/aalferov/nfv-k8s/raw/master/components/loadbalancer/metallb-config.yaml?private_token=$PRIVATE_TOKEN >> $CLUSTER/components/loadbalancer/metallb-config.yaml
```

and change the [MetalLB IP range] according to your needs. When the change
is ready, create the configuration:

```
$ kubectl create -f $CLUSTER/components/loadbalancer/metallb-config.yaml
```

See also:

* [Layer 2 Mode Tutorial →]

### IP Range Change

To change the IP range, edit the configuration file again and apply it:

```
$ kubectl apply -f $CLUSTER/components/loadbalancer/metallb-config.yaml
```

The load balancer does not need to be restarted. See the speaker logs for the
changes applied:

```
$ SPEAKER_POD=$(kubectl -n metallb-system get po -l app=metallb -l component=speaker -o jsonpath={.items[0].metadata.name})
$ kubectl -n metallb-system logs $SPEAKER_POD
```

## Usage example

As an example we deploy a service that depends on both TCP and UDP protocols.
[Iperf3] when running as a server can serve UDP traffic, but to negotiate with
Iperf3 client they use TCP. This creates a requirement of both protocols
availability on the same IP address.

First, we deploy the Iperf3 server:

```
$ kubectl run iperf3-server --image=aialferov/nettools --command -- iperf3 -s
```

Using the [Example manifest] we create two load balancers with use of the
[MetalLB IP address sharing] feature to serve both TCP and UDP traffic on the
same IP address (requires [Private Token]):

```
$ kubectl create -f https://gitlab.tpip.net/aalferov/nfv-k8s/raw/master/components/loadbalancer/example.yaml?private_token=$PRIVATE_TOKEN
```

Iperf3 client is needed to verify the server works as expected. Please refer the
[Iperf3 download] webpage to get the executable binary for your OS.

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

### Example Clean Up

Do delete all the example related resources (requires [Private Token]):

```
$ kubectl delete -f https://gitlab.tpip.net/aalferov/nfv-k8s/raw/master/components/loadbalancer/example.yaml?private_token=$PRIVATE_TOKEN
$ kubectl delete deployment iperf3-server
```

<!-- Links -->

[Iperf3]: https://iperf.fr
[MetalLB]: https://metallb.universe.tf
[LoadBalancer]: https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer
[Iperf3 download]: https://iperf.fr/iperf-download.php
[Example manifest]: ../../components/loadbalancer/example.yaml
[MetalLB IP range]: ../../components/loadbalancer/metallb-config.yaml#L12
[Layer2 configuration]: https://metallb.universe.tf/configuration/#layer-2-configuration
[MetalLB IP address sharing]: https://metallb.universe.tf/usage/#ip-address-sharing
[MetalLB configuration manifest]: ../../components/loadbalancer/metallb-config.yaml

[Layer 2 Mode Tutorial →]: https://metallb.universe.tf/tutorial/layer2

[Private Token]: ../gitlab_private_token.md
