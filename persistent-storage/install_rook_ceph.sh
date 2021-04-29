#!/bin/bash

set -euo pipefail

if ! kubectl describe namespace rook-ceph; then
				kubectl create namespace rook-ceph
fi

helm repo add rook-release https://charts.rook.io/release
helm upgrade rook-ceph rook-release/rook-ceph --install --namespace rook-ceph --version v1.5.3 --wait

# Need to use ceph v15.2.7 to be able to use partitions
# See https://github.com/rook/rook/issues/6849
kubectl apply --namespace rook-ceph -f cluster-test.yaml
kubectl apply --namespace rook-ceph -f storageclass-test.yaml

kubectl --namespace rook-ceph get cephclusters.ceph.rook.io --watch
