#!/bin/bash

set -eou pipefail

CLUSTER=${CLUSTER:-$(whoami)-demo-cluster}

pushd kubespray
. .venv/bin/activate

ansible -i inventory/${CLUSTER}/inventory.ini -m ping all

ansible-playbook -i inventory/${CLUSTER}/inventory.ini cluster.yml -b -v

CONTROL_PLANE_LB_IP=$(terraform -chdir=contrib/terraform/exoscale/ output -raw control_plane_lb_ip_address)
sed -i -e "s!server: .*!server: https://${CONTROL_PLANE_LB_IP}:6443!" inventory/${CLUSTER}/artifacts/admin.conf

