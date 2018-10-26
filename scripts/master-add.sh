#!/bin/sh

ALPHA_PHASE="kubeadm alpha phase"
CONFIG="--config kubeadm-config.yaml"

#sudo tar xf kubernetes.tgz -C /etc
#sudo chown -R root:root /etc/kubernetes
##rm kubernetes.tgz
#
#sudo $ALPHA_PHASE certs all $CONFIG
#sudo $ALPHA_PHASE kubelet config write-to-disk $CONFIG
#sudo $ALPHA_PHASE kubelet write-env-file $CONFIG
#sudo $ALPHA_PHASE kubeconfig kubelet $CONFIG
#sudo systemctl start kubelet

#sudo -E kubectl -n kube-system get po -l component=etd -o jsonpath='{range .items[*]}{.spec.nodeName}{"=https://"}{.status.hostIP}{":2380,"}{end}'

echo "sudo -E \
          kubectl --kubeconfig /etc/kubernetes/admin.conf \
                  --namespace kube-system \
                  exec etcd-${EXISTING_HOSTNAME} -- \
              etcdctl --ca-file /etc/kubernetes/pki/etcd/ca.crt \
                      --key-file /etc/kubernetes/pki/etcd/peer.key \
                      --cert-file /etc/kubernetes/pki/etcd/peer.crt \
                      --endpoints=https://${EXISTING_IP}:2379 \
                  member add $NEW_HOSTNAME https://${NEW_IP}:2380"

#sudo $ALPHA_PHASE etcd local $CONFIG
#sudo $ALPHA_PHASE kubeconfig all $CONFIG
#sudo $ALPHA_PHASE controlplane all $CONFIG
#sudo $ALPHA_PHASE kubelet config annotate-cri $CONFIG
#sudo $ALPHA_PHASE mark-master $CONFIG

