#!/bin/bash

set -euo pipefail

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.3.1/cert-manager.crds.yaml

sed -e "s/EMAIL_PLACEHOLDER/${EMAIL}/g" issuer.yml > rendered-issuer.yml

kubectl apply -f rendered-issuer.yml

kubectl create namespace certmanager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager
