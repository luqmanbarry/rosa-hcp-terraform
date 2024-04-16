#!/bin/bash

echo "Log in to your cluster as cluster-admin"

VAULT_ADDR_DOMAIN="apps.rosa-xb8cn.dlhq.p1.openshiftapps.com"

sed "s/VAULT_ADDR_DOMAIN/$VAULT_ADDR_DOMAIN/g" ".ci/hashicorp-vault-k8s-crs.yaml" | oc apply -f -

sleep 60

echo
echo "Vault Address: \"https://$(oc get route vault -n vault -o jsonpath='{.spec.host}')\""
echo "Vault Root Token: \"$(oc get secret vault-init -n vault -o jsonpath='{.data.root_token}' | base64 -d)\""
echo