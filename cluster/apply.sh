#!/bin/bash

CLUSTER=${CLUSTER:-$(whoami)-demo-cluster}

cd kubespray/inventory/${CLUSTER}

terraform -chdir=../../contrib/terraform/exoscale init

terraform -chdir=../../contrib/terraform/exoscale apply -var-file $(pwd)/${CLUSTER}.tfvars

cp ../../contrib/terraform/exoscale/inventory.ini .
