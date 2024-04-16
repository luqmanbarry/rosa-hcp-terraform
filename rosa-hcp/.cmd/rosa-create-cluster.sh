#!/bin/bash
set -e

# export AWS_ACCESS_KEY_ID='<VALUE>'
# export AWS_SECRET_ACCESS_KEY='<VALUE>'
# export AWS_SESSION_TOKEN="" # OPTIONAL IN CERTAIN ENV
export AWS_REGION="us-east-1"
# export OCM_TOKEN="<VALUE>"

BUSINESS_UNIT="sales"
CLUSTER_NAME="rosa-sts-100"
OPENSHIFT_ENVIRONMENT="lab"
BASE_DNS_DOMAIN="sales.corporate.com"
CLUSTER_DOMAIN="apps.rosa.$BUSINESS_UNIT.$CLUSTER_NAME.$OPENSHIFT_ENVIRONMENT.$BASE_DNS_DOMAIN"
OCP_VERSION="4.15.5"
HTTP_PROXY="http://proxy.example.com"
HTTPS_PROXY="http://proxy.example.com"
NO_PROXY=""
PRIVATE_LINK=true
SUBNET_IDS="subnet-123,subnet-123,subnet-123"
AVAILABILITY_ZONES="us-east-2a,us-east-2b,us-east-2c"
COMPUTE_MACHINE_TYPE="m5.xlarge"
WORKER_REPLICAS=3
ENABLE_CLUSTER_AUTOSCALE=true
AUTOSCALE_MIN=3
AUTOSCALE_MAX=30
MACHINE_CIDR="10.54.160.0/21"
POD_CIDR="172.128.0.0/14"
SERVICE_CIDR="172.127.0.0/16"
ADMIN_PASSWORD="SomeRandomPassword777"


echo "=================================================="
echo "==> AWS - Validate if user logged in"
echo "=================================================="
aws2 sts get-caller-identity

echo "=================================================="
echo "==> rosa-cli Login: '$CLUSTER_NAME'"
echo "=================================================="
rosa login --token="$OCM_TOKEN"
rosa whoami

echo "=================================================="
echo "==> rosa list account-roles: '$CLUSTER_NAME'"
echo "=================================================="
rosa list account-roles

echo "=================================================="
echo "==> Installing ROSA Cluster: '$CLUSTER_NAME'"
echo "=================================================="
rosa create cluster \
  --cluster-name="$CLUSTER_NAME" \
  --sts \
  --multi-az \
  --region $AWS_REGION \
  --version $OCP_VERSION \
  --compute-machine-type $COMPUTE_MACHINE_TYPE \
  --enable-autoscaling \
  --autoscaler-scale-down-enabled \
  --min-replicas $AUTOSCALE_MIN \
  --max-replicas $AUTOSCALE_MAX \
  --subnet-ids $SUBNET_IDS \
  --pod-cidr $POD_CIDR \
  --service-cidr $SERVICE_CIDR \
  --operator-roles-prefix $CLUSTER_NAME \
  --disable-workload-monitoring false \
  --create-admin-user \
  --cluster-admin-password $ADMIN_PASSWORD \
  --http-proxy $HTTP_PROXY \
  --https-proxy $HTTPS_PROXY \
  --no-proxy $NO_PROXY \
  --private-link \
  --private \
  --mode "auto" \
  --yes
  # --dry-run
  # --base-domain $CLUSTER_DOMAIN \
  # --replicas $WORKER_REPLICAS \
  # --machine-cidr $MACHINE_CIDR \
  #  --availability-zones $AVAILABILITY_ZONES \

echo "=================================================="
echo "==> Creating operator-roles for cluster: '$CLUSTER_NAME'"
echo "=================================================="
rosa create operator-roles --cluster $CLUSTER_NAME \
  --mode "auto" \
  --yes

echo "=================================================="
echo "==> Creating oidc-provider for cluster: '$CLUSTER_NAME'"
echo "=================================================="
rosa create oidc-provider --managed --cluster $CLUSTER_NAME \
  --mode "auto" \
  --yes

echo "=================================================="
echo "==> Tailing logs for cluster: '$CLUSTER_NAME'"
echo "=================================================="
rosa logs install \
  --cluster $CLUSTER_NAME \
  --watch

