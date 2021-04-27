#!/bin/bash

CLUSTER=${CLUSTER:-$(whoami)-demo-cluster}

export KUBECONFIG=$(pwd)/kubespray/inventory/${CLUSTER}/artifacts/admin.conf
export CONTROL_PLANE_LB_IP=$(terraform -chdir=$(pwd)/kubespray/contrib/terraform/exoscale/ output -raw control_plane_lb_ip_address)
