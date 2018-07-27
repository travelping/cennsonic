# Exec Format Error

Cannot start container on one node, whereas can do it on the other one.

```
$ sudo docker run --rm 953de4b3d847
standard_init_linux.go:178: exec user process caused "exec format error"
```

```
$ sudo docker run --rm --entrypoint ls 953de4b3d847
container_linux.go:247: starting container process caused "exec: \"ls\": executable file not found in $PATH"
docker: Error response from daemon: oci runtime error: container_linux.go:247: starting container process caused "exec: \"ls\": executable file not found in $PATH".
```

Although "ls" is definitelly there and works on the other node.

Trying to find differencies:

- Docker version is the same on the both nodes:
- Linux kernel is the same on the both nodes
- `docker inspect 953de4b3d847` provides the same output
- `docker --digests` provides the same output

The first difference found is docker save output:

```
$ docker save 953de4b3d847 | md5sum
Error response from daemon: file integrity checksum failed for "./sbin/insserv"
d41d8cd98f00b204e9800998ecf8427e  -
```

whiles on the healthy node:

```
$ docker save 953de4b3d847 | md5sum
e85700a3fe48c92ffdedde25d7a847ff  -
```

Deleting the image and reloading solved the issue.

The reason why the image was corrupted is unknown.
