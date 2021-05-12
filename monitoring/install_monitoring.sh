#!/bin/bash

set -euo pipefail

CLUSTER=${CLUSTER:-$(whoami)-demo-cluster}

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

cp values.yaml rendered-values.yaml
sed -i -e "s/DOMAIN_PLACEHOLDER/${CLUSTER}.${TOP_LEVEL_DOMAIN}/g" rendered-values.yaml
sed -i -e "s/OIDC_CLIENT_SECRET_PLACEHOLDER/${OIDC_CLIENT_SECRET}/g" rendered-values.yaml

helm upgrade --install --namespace=monitoring monitoring prometheus-community/kube-prometheus-stack --values=rendered-values.yaml --create-namespace
