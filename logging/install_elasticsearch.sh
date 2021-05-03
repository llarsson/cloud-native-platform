#!/bin/bash

set -euo pipefail

kubectl apply -f https://download.elastic.co/downloads/eck/1.5.0/all-in-one.yaml

sleep 30

kubectl apply -f elasticsearch.yml

sleep 30

echo "Kibana lets you log in using the 'elastic' user with the following password: $(kubectl get secret quickstart-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode; echo)"
echo "To log in to Kibana, run the following: kubectl port-forward service/quickstart-kb-http 5601"
