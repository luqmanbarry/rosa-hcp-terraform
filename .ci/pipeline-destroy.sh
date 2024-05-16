#!/bin/bash

set +e

echo "#########################################################################################################"
echo "=================================================="
echo "==> Set Environment Variables"
echo "=================================================="

. .ci/user-inputs.sh

WORKING_DIRECTORY="$(pwd)"

echo "=================================================="
echo "==> AWS Authentication"
echo "=================================================="

aws sts get-caller-identity

echo "#########################################################################################################"
TF_MODULE="custom-ingress"
BACKEND_KEY="${TF_VAR_openshift_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
BACKEND_PATH="${TF_MODULE}"
TFVARS_FILE="../tfvars/${TF_VAR_business_unit}/${TF_VAR_aws_account}/${TF_VAR_cluster_name}.tfvars"
echo "=================================================="
echo "==> Module - $TF_MODULE"
echo "=================================================="

cd "${TF_MODULE}"
rm -rf .terraform || true && rm -rf .terraform.lock.hcl || true
unset TF_WORKSPACE
terraform init \
  -backend-config="bucket=${TF_VAR_tfstate_s3_bucket_name}" \
  -backend-config="key=${BACKEND_KEY}" \
  -backend-config="region=${BUCKET_REGION}"
terraform plan -destroy -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
terraform apply "$TF_MODULE.plan"
cd "${WORKING_DIRECTORY}"

echo "#########################################################################################################"
TF_MODULE="vault-k8s-auth"
BACKEND_KEY="${TF_VAR_openshift_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
BACKEND_PATH="${TF_MODULE}"
TFVARS_FILE="../tfvars/${TF_VAR_business_unit}/${TF_VAR_aws_account}/${TF_VAR_cluster_name}.tfvars"
echo "=================================================="
echo "==> Module - $TF_MODULE"
echo "=================================================="

cd "${TF_MODULE}"
rm -rf .terraform || true && rm -rf .terraform.lock.hcl || true
unset TF_WORKSPACE
terraform init \
  -backend-config="bucket=${TF_VAR_tfstate_s3_bucket_name}" \
  -backend-config="key=${BACKEND_KEY}" \
  -backend-config="region=${BUCKET_REGION}" 
terraform plan -destroy -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
terraform apply "$TF_MODULE.plan"
cd "${WORKING_DIRECTORY}"

echo "#########################################################################################################"
TF_MODULE="rosa-hcp"
BACKEND_KEY="${TF_VAR_openshift_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
BACKEND_PATH="${TF_MODULE}"
TFVARS_FILE="../tfvars/${TF_VAR_business_unit}/${TF_VAR_aws_account}/${TF_VAR_cluster_name}.tfvars"
echo "=================================================="
echo "==> Module - $TF_MODULE"
echo "=================================================="

cd "${TF_MODULE}"
rm -rf .terraform || true && rm -rf .terraform.lock.hcl || true
unset TF_WORKSPACE
terraform init \
  -backend-config="bucket=${TF_VAR_tfstate_s3_bucket_name}" \
  -backend-config="key=${BACKEND_KEY}" \
  -backend-config="region=${BUCKET_REGION}"
terraform plan -destroy -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
terraform apply "$TF_MODULE.plan"
cd "${WORKING_DIRECTORY}"

echo "#########################################################################################################"
TF_MODULE="account-setup"
BACKEND_KEY="${TF_VAR_openshift_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
BACKEND_PATH="${TF_MODULE}"
TFVARS_FILE="../tfvars/${TF_VAR_business_unit}/${TF_VAR_aws_account}/${TF_VAR_cluster_name}.tfvars"
echo "=================================================="
echo "==> Module - $TF_MODULE"
echo "=================================================="

cd "${TF_MODULE}"
rm -rf .terraform || true && rm -rf .terraform.lock.hcl || true
unset TF_WORKSPACE
terraform init \
  -backend-config="bucket=${TF_VAR_tfstate_s3_bucket_name}" \
  -backend-config="key=${BACKEND_KEY}" \
  -backend-config="region=${BUCKET_REGION}"
terraform plan -destroy -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
terraform apply "$TF_MODULE.plan"
cd "${WORKING_DIRECTORY}"
