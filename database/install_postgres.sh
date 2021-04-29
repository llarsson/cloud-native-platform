#!/bin/bash

set -euo pipefail

pushd postgres-operator

helm install postgres-operator ./charts/postgres-operator -f ./charts/postgres-operator/values-crd.yaml --wait

kubectl get pod -l app.kubernetes.io/name=postgres-operator
