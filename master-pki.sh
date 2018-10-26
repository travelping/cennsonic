#!/bin/sh

mkdir -p kubernetes/pki/etcd
sudo cp /etc/kubernetes/pki/{ca.{crt,key},sa.{key,pub}} kubernetes/pki
sudo cp /etc/kubernetes/pki/front-proxy-ca.{crt,key} kubernetes/pki
sudo cp /etc/kubernetes/pki/etcd/ca.{crt,key} kubernetes/pki/etcd
sudo cp /etc/kubernetes/admin.conf kubernetes

sudo chown -R $USER:$USER kubernetes
tar zcf kubernetes.tgz kubernetes
rm -rf kubernetes
