#!/bin/bash

cluster="$1"
server="$2"
username="$3"

days=30

company="Travelping"
kubeconfig=$username.conf

if [ -z "$cluster" ] || [ -z "$server" ] || [ -z "$username" ]; then
    echo "Usage: $(basename $0) <Cluster> <Server> <Username>"
    echo ""
    echo "You will need ca.pem and ca-key.pem files from the cluster:"
    echo "scp <node>:/etc/kubernetes/ssl/ca{\"\",\"-key\"}.pem ./"
    exit 1
fi

openssl genrsa -out $username-key.pem 2048

openssl \
    req -new -key $username-key.pem \
    -out $username.pem \
    -subj "/CN=$username/O=$company"

openssl \
    x509 -req -in $username.pem \
    -CA ca.pem \
    -CAkey ca-key.pem \
    -CAcreateserial \
    -out $username.pem \
    -days $days

kubectl config set-cluster $cluster \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=$server \
    --kubeconfig=$kubeconfig

kubectl config set-credentials $username-$cluster \
    --client-certificate=$username.pem \
    --client-key=$username-key.pem \
    --embed-certs=true \
    --kubeconfig=$kubeconfig

kubectl config set-context $username-$cluster \
    --cluster=$cluster \
    --user=$username-$cluster \
    --kubeconfig=$kubeconfig

kubectl config use-context $username-$cluster \
    --kubeconfig=$kubeconfig

kubectl config set-context $username-$cluster \
    --namespace=$username \
    --kubeconfig=$kubeconfig
