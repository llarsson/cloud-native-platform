#!/bin/bash

set -eou pipefail

CLUSTER=${CLUSTER:-$(whoami)-demo-cluster}
SSH_KEY=${SSH_KEY:-${HOME}/.ssh/id_rsa.pub}

cp -r kubespray/inventory/sample kubespray/inventory/${CLUSTER}
cp default.tfvars kubespray/inventory/$CLUSTER/${CLUSTER}.tfvars

sed -i -e "s!KEY_PLACEHOLDER!$(cat ${SSH_KEY})!g" kubespray/inventory/${CLUSTER}/${CLUSTER}.tfvars
sed -i -e "s!PREFIX_PLACEHOLDER!${CLUSTER}!g" kubespray/inventory/${CLUSTER}/${CLUSTER}.tfvars

sed -i -e "s!# kubeconfig_localhost: false!kubeconfig_localhost: true!g" kubespray/inventory/${CLUSTER}/group_vars/k8s-cluster/k8s-cluster.yml

