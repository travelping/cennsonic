#!/bin/sh

export KUBECONFIG=/etc/kubernetes/admin.conf

sudo kubeadm init --config kubeadm-config.yaml

sudo -E kubectl apply -f calico-rbac-kdd.yaml
sudo -E kubectl apply -f calico.yaml
sudo -E kubectl apply -f keepalived.yaml
