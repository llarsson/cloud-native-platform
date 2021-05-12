#!/bin/bash

set -eou pipefail
CLUSTER=${CLUSTER:-$(whoami)-demo-cluster}

cp dex-values.yml rendered-dex-values.yml
sed -i -e "s/OIDC_CLIENT_SECRET_PLACEHOLDER/${OIDC_CLIENT_SECRET}/g" rendered-dex-values.yml
sed -i -e "s/CLIENT_ID_PLACEHOLDER/${DEX_CLIENT_ID}/g" rendered-dex-values.yml
sed -i -e "s/CLIENT_SECRET_PLACEHOLDER/${DEX_CLIENT_SECRET}/g" rendered-dex-values.yml
sed -i -e "s/DOMAIN_PLACEHOLDER/${CLUSTER}.${TOP_LEVEL_DOMAIN}/g" rendered-dex-values.yml
sed -i -e "s/ADMIN_EMAIL_PLACEHOLDER/${ADMIN_EMAIL}/g" rendered-dex-values.yml

SA_FILE_CONTENTS=$(base64 -w0 ${SA_FILE})
sed -e "s/SA_FILE_PLACEHOLDER/${SA_FILE_CONTENTS}/g" google-sa-secret.yml > rendered-google-sa-secret.yml

kubectl apply -f rendered-google-sa-secret.yml
helm repo add dex https://charts.dexidp.io
helm repo update
helm upgrade --install --values rendered-dex-values.yml dex dex/dex

cp admin-role.yml rendered-admin-role.yml
sed -i -e "s/ADMIN_GROUP_PLACEHOLDER/${ADMIN_GROUP}/g" rendered-admin-role.yml
kubectl apply -f rendered-admin-role.yml

pushd ../cluster/
sed -i -e "s!# kube_oidc_auth: false!kube_oidc_auth: true!g" kubespray/inventory/${CLUSTER}/group_vars/k8s-cluster/k8s-cluster.yml
sed -i -e "s!# kube_oidc_url: .*!kube_oidc_url: https://dex.${CLUSTER}.${TOP_LEVEL_DOMAIN}!g" kubespray/inventory/${CLUSTER}/group_vars/k8s-cluster/k8s-cluster.yml
sed -i -e "s!# kube_oidc_client_id: .*!kube_oidc_client_id: kubelogin!g" kubespray/inventory/${CLUSTER}/group_vars/k8s-cluster/k8s-cluster.yml
sed -i -e "s!# kube_oidc_username_claim: .*!kube_oidc_username_claim: email!g" kubespray/inventory/${CLUSTER}/group_vars/k8s-cluster/k8s-cluster.yml
sed -i -e "s!# kube_oidc_groups_claim: .*!kube_oidc_groups_claim: groups!g" kubespray/inventory/${CLUSTER}/group_vars/k8s-cluster/k8s-cluster.yml
./run_ansible.sh

cat >> $KUBECONFIG <<HERE
- name: oidc
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: kubectl
      args:
      - oidc-login
      - get-token
      - --oidc-issuer-url=https://dex.${CLUSTER}.${TOP_LEVEL_DOMAIN}
      - --oidc-client-id=kubelogin
      - --oidc-client-secret=${OIDC_CLIENT_SECRET}
      - --oidc-extra-scope=email
      - --oidc-extra-scope=groups
HERE
kubectl config set-context --current --user=oidc
echo "Your kubectl is now set up to use OpenID Connect login"
