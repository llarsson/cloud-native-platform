#!/bin/bash

CLUSTER=${CLUSTER:-$(whoami)-demo-cluster}

pushd kubespray/inventory/${CLUSTER}

terraform -chdir=../../contrib/terraform/exoscale init
terraform -chdir=../../contrib/terraform/exoscale destroy -var-file $(pwd)/${CLUSTER}.tfvars

