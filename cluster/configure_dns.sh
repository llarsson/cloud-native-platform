#!/bin/bash

set -eou pipefail

CLUSTER=${CLUSTER:-$(whoami)-demo-cluster}

pushd kubespray
INGRESS_CONTROLLER_LB_IP=$(terraform -chdir=contrib/terraform/exoscale/ output -raw ingress_controller_lb_ip_address)

exo dns add A ${TOP_LEVEL_DOMAIN} -a ${INGRESS_CONTROLLER_LB_IP} -n "*.${CLUSTER}"
