#!/bin/bash

set -euo pipefail
CLUSTER=${CLUSTER:-$(whoami)-demo-cluster}

helm repo add harbor https://helm.goharbor.io

cp values.yaml rendered-values.yaml
sed -i -e "s/DOMAIN_PLACEHOLDER/${CLUSTER}.${TOP_LEVEL_DOMAIN}/g" rendered-values.yaml

helm upgrade --install --namespace=harbor --create-namespace harbor harbor/harbor --values=rendered-values.yaml

