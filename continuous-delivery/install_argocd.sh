#!/bin/bash

set -euo pipefail

CLUSTER=${CLUSTER:-$(whoami)-demo-cluster}

cp argocd.yaml rendered-argocd.yaml
sed -i -e "s/DOMAIN_PLACEHOLDER/${CLUSTER}.${TOP_LEVEL_DOMAIN}/g" rendered-argocd.yaml
sed -i -e "s/OIDC_CLIENT_SECRET_PLACEHOLDER/${OIDC_CLIENT_SECRET}/g" rendered-argocd.yaml

cp argocd-ingress.yaml rendered-argocd-ingress.yaml
sed -i -e "s/DOMAIN_PLACEHOLDER/${CLUSTER}.${TOP_LEVEL_DOMAIN}/g" rendered-argocd-ingress.yaml

if ! kubectl get namespace argocd; then
				kubectl create namespace argocd
fi
kubectl apply --namespace argocd -f rendered-argocd.yaml
kubectl apply --namespace argocd -f rendered-argocd-ingress.yaml
