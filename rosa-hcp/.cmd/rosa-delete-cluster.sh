#!/bin/bash

CLUSTER_NAME="rosa-sts-100"
# export AWS_ACCESS_KEY_ID='<VALUE>'
# export AWS_SECRET_ACCESS_KEY='<VALUE>'
# export AWS_SESSION_TOKEN="" # OPTIONAL IN CERTAIN ENV
export AWS_REGION="us-east-1"
# export OCM_TOKEN="<VALUE>"

echo "=================================================="
echo "==> AWS - Validate if user logged in"
echo "=================================================="
aws2 sts get-caller-identity

echo "=================================================="
echo "==> rosa-cli Login: '$CLUSTER_NAME'"
echo "=================================================="
rosa login --token="$OCM_TOKEN"

echo "=================================================="
echo "==> Deleting ROSA Cluster: '$CLUSTER_NAME'"
echo "=================================================="
rosa delete cluster --cluster $CLUSTER_NAME --mode auto --yes

echo "=================================================="
echo "==> Deleting operator-roles for cluster: '$CLUSTER_NAME'"
echo "=================================================="
rosa delete operator-roles --cluster $CLUSTER_NAME --mode auto --yes

echo "=================================================="
echo "==> Deleting oidc-provider for cluster: '$CLUSTER_NAME'"
echo "=================================================="
rosa delete oidc-provider --cluster $CLUSTER_NAME --mode auto --yes

