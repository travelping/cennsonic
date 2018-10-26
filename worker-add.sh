#!/bin/sh

#sudo kubeadm token list | tail -n-1 | sed 's/ .*//'

#openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | \
    openssl rsa -pubin -outform der 2>/dev/null | \
    openssl dgst -sha256 -hex | sed 's/^.* //'

sudo kubeadm join --token TOKEN MASTER_IP:MASTER_PORT \
                  --discovery-token-ca-cert-hash sha256:HASH
