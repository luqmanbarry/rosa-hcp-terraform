#!/bin/bash

CLUSTER_DOMAIN="$(echo $1 | xargs)"

if [ -z "$CLUSTER_DOMAIN" ];
then
  echo "OpenShift cluster domain is required."
  echo "Example: .ci/vault-deploy.sh 'apps.classic-101.9kvd.p1.openshiftapps.com'"
  exit 1
fi

echo "Log in to your cluster as cluster-admin"

sed "s/VAULT_ADDR_DOMAIN/$CLUSTER_DOMAIN/g" ".ci/hashicorp-vault-k8s-crs.yaml" | oc replace -f -

sleep 60

echo
echo "Vault Address: \"https://$(oc get route vault -n vault -o jsonpath='{.spec.host}')\""
echo "Vault Root Token: \"$(oc get secret vault-init -n vault -o jsonpath='{.data.root_token}' | base64 -d)\""
echo