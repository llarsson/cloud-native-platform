#!/bin/bash

set -euo pipefail

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install --values nginx-values.yml ingress-nginx ingress-nginx/ingress-nginx
