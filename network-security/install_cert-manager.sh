#!/bin/bash

set -euo pipefail

helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade cert-manager jetstack/cert-manager --namespace cert-manager --install --create-namespace --version v1.3.1 --set installCRDs=true --wait

sed -e "s/EMAIL_PLACEHOLDER/${EMAIL}/g" staging-issuer.yml > rendered-issuer.yml
kubectl apply -f rendered-issuer.yml
