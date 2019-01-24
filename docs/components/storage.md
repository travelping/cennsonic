# Cluster Storage

In case of a Kubernetes cluster installation where cloud provided persistent
storage subsystem is not available (for example on bare metal) or cannot be used
for any reason, there is an option to use [Rook] — the orchestrator for [Ceph].

## Installation

To install Rook, the following components should be created in the cluster (in
this order):

- [Rook Operator]
- [Rook Cluster]
- [Rook Storage Class]

We create them using the manifests:

```
# Rook operator
$ kubectl apply -f https://raw.githubusercontent.com/travelping/cennsonic/master/components/storage/rook-operator.yaml

# Rook cluster
$ kubectl apply -f https://raw.githubusercontent.com/travelping/cennsonic/master/components/storage/rook-cluster.yaml

# Rook storage class
$ kubectl apply -f https://raw.githubusercontent.com/travelping/cennsonic/master/components/storage/rook-storageclass.yaml
```

See also:

* [Rook Quick Start (Ceph Storage) →]
* [Storage Backup and Restore →] **WiP**
* [Storage Resize →] **WiP**

## Usage Example

After installation, the "rook-ceph-block" value can be used as a storage class
name for [PVC]. We create a [StatefulSet] defined in the [Usage Example] to
demonstrate that:

```
$ kubectl apply -f https://raw.githubusercontent.com/travelping/cennsonic/master/components/storage/example.yaml
```

Now we can store something in the mounted directory, remove the StatefulSet,
create it again, and see our data is still there:

```
# Store data and display it
$ kubectl exec rook-usage-example-0 -- sh -c 'echo 1 > /data/rook-usage-example/1.txt'
$ kubectl exec rook-usage-example-0 cat /data/rook-usage-example/1.txt
1

# Delete StatefulSet
$ kubectl delete -f https://raw.githubusercontent.com/travelping/cennsonic/master/components/storage/example.yaml
service "rook-usage-example" deleted
statefulset.apps "rook-usage-example" deleted

# Create StatefulSet again
$ kubectl apply -f https://raw.githubusercontent.com/travelping/cennsonic/master/components/storage/example.yaml
service "rook-usage-example" created
statefulset.apps "rook-usage-example" created

# Display the data previously stored
$ kubectl exec rook-usage-example-0 cat /data/rook-usage-example/1.txt
1
```

To remove the StatefulSet and the used Volume comletely we have to remove [PVC]
also:

```
# Delete StatefulSet
$ kubectl delete -f https://raw.githubusercontent.com/travelping/cennsonic/master/components/storage/example.yaml
service "rook-usage-example" deleted
statefulset.apps "rook-usage-example" deleted

# Delete PVC
$ kubectl delete pvc rook-usage-example-rook-usage-example-0
persistentvolumeclaim "rook-usage-example-rook-usage-example-0" deleted
```

Now after creation the workload again, our data is gone:

```
# Create StatefulSet again
$ kubectl apply -f https://raw.githubusercontent.com/travelping/cennsonic/master/components/storage/example.yaml
service "rook-usage-example" created
statefulset.apps "rook-usage-example" created

# The file is gone
$ kubectl exec rook-usage-example-0 cat /data/rook-usage-example/1.txt
cat: can't open '/data/rook-usage-example/1.txt': No such file or directory
command terminated with exit code 1
```

### Example Clean Up

To delete all the example related objects:

```
$ kubectl delete -f https://raw.githubusercontent.com/travelping/cennsonic/master/components/storage/example.yaml
$ kubectl delete pvc rook-usage-example-rook-usage-example-0
```

<!-- Links -->

[PVC]: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims
[StatefulSet]: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset
[Usage Example]: ../../components/storage/example.yaml

[Ceph]: https://ceph.com
[Rook]: https://rook.io/docs/rook/v0.9
[Rook Cluster]: ../../components/storage/rook-cluster.yaml
[Rook Operator]: ../../components/storage/rook-operator.yaml
[Rook Storage Class]: ../../components/storage/rook-storageclass.yaml

[Storage Resize →]: resize.md
[Storage Backup and Restore →]: backup_and_restore.md
[Rook Quick Start (Ceph Storage) →]: https://rook.io/docs/rook/v0.9/ceph-quickstart.html
