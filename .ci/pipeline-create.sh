#!/bin/bash

set -e

echo "#########################################################################################################"
echo "=================================================="
echo "==> Set Environment Variables"
echo "=================================================="

if [[ ! -f ".ci/user-inputs.sh" ]]; then
  echo "Missing .ci/user-inputs.sh"
  echo "Create it from .ci/user-inputs.sh.example, then re-run."
  exit 1
fi

. .ci/user-inputs.sh

WORKING_DIRECTORY="$(pwd)"

echo "=================================================="
echo "==> AWS Authentication"
echo "=================================================="

aws sts get-caller-identity


echo "#########################################################################################################"
TF_MODULE="tfstate-config"
BACKEND_KEY="${TF_VAR_openshift_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
BACKEND_PATH="${TF_MODULE}"
TFVARS_FILE="../tfvars/admin/admin.tfvars"
echo "=================================================="
echo "==> Module - $TF_MODULE"
echo "=================================================="

if !(aws s3api head-bucket --region="${TF_VAR_tfstate_bucket_region}" --bucket "${TF_VAR_tfstate_s3_bucket_name}" 2>/dev/null);
then
  echo "===> TFState bucket does not exists. Creating..."
  cd "${TF_MODULE}"
  rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true)
  unset TF_WORKSPACE
  terraform init
  terraform plan -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
  terraform apply "$TF_MODULE.plan"
  cd ${WORKING_DIRECTORY}
else
  echo "===> TFState bucket exists. Skipping..."
fi

echo "#########################################################################################################"
TF_MODULE="account-setup"
BACKEND_KEY="${TF_VAR_openshift_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
BACKEND_PATH="${TF_MODULE}"
TFVARS_FILE="../tfvars/admin/admin.tfvars"
echo "=================================================="
echo "==> Module - $TF_MODULE"
echo "=================================================="
cd "${TF_MODULE}"
rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true)
unset TF_WORKSPACE
terraform init \
  -backend-config="bucket=${TF_VAR_tfstate_s3_bucket_name}" \
  -backend-config="key=${BACKEND_KEY}" \
  -backend-config="region=${TF_VAR_tfstate_bucket_region}"
terraform plan -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
terraform apply "$TF_MODULE.plan"
cd ${WORKING_DIRECTORY}

echo "#########################################################################################################"
TF_MODULE="tfvars-prep"
BACKEND_KEY="${TF_VAR_openshift_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
BACKEND_PATH="${TF_MODULE}"
TFVARS_FILE="../tfvars/admin/admin.tfvars"
echo "=================================================="
echo "==> Module - $TF_MODULE"
echo "=================================================="
cd "${TF_MODULE}"
rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true)
unset TF_WORKSPACE
terraform init \
  -backend-config="bucket=${TF_VAR_tfstate_s3_bucket_name}" \
  -backend-config="key=${BACKEND_KEY}" \
  -backend-config="region=${TF_VAR_tfstate_bucket_region}"
terraform plan -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
terraform apply "$TF_MODULE.plan"
cd ${WORKING_DIRECTORY}

echo "#########################################################################################################"
TF_MODULE="git-tfvars-file"
BACKEND_KEY="${TF_VAR_openshift_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
BACKEND_PATH="${TF_MODULE}"
TFVARS_FILE="../tfvars/${TF_VAR_business_unit}/${TF_VAR_aws_account}/${TF_VAR_cluster_name}.tfvars"
echo "=================================================="
echo "==> Module - $TF_MODULE"
echo "=================================================="
cd "${TF_MODULE}"
rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true)
unset TF_WORKSPACE
terraform init \
  -backend-config="bucket=${TF_VAR_tfstate_s3_bucket_name}" \
  -backend-config="key=${BACKEND_KEY}" \
  -backend-config="region=${TF_VAR_tfstate_bucket_region}"
terraform plan -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
terraform apply "$TF_MODULE.plan"
cd ${WORKING_DIRECTORY}

echo "#########################################################################################################"
TF_MODULE="rosa-hcp"
BACKEND_KEY="${TF_VAR_openshift_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
BACKEND_PATH="${TF_MODULE}"
TFVARS_FILE="../tfvars/${TF_VAR_business_unit}/${TF_VAR_aws_account}/${TF_VAR_cluster_name}.tfvars"
echo "=================================================="
echo "==> Module - $TF_MODULE"
echo "=================================================="
cd "${TF_MODULE}"
rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true)
unset TF_WORKSPACE
terraform init \
  -backend-config="bucket=${TF_VAR_tfstate_s3_bucket_name}" \
  -backend-config="key=${BACKEND_KEY}" \
  -backend-config="region=${TF_VAR_tfstate_bucket_region}"
terraform plan -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
terraform apply "$TF_MODULE.plan" | tee "${TF_VAR_cluster_name}-logs.out"
terraform output -json | tee "${TF_VAR_cluster_name}-output.out"
cd ${WORKING_DIRECTORY}

echo "#########################################################################################################"
TF_MODULE="kube-config"
BACKEND_KEY="${TF_VAR_openshift_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
BACKEND_PATH="${TF_MODULE}"
TFVARS_FILE="../tfvars/${TF_VAR_business_unit}/${TF_VAR_aws_account}/${TF_VAR_cluster_name}.tfvars"
echo "=================================================="
echo "===========> Module - $TF_MODULE "
echo "=================================================="
cd "${TF_MODULE}"
rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true)
unset TF_WORKSPACE
terraform init \
  -backend-config="bucket=${TF_VAR_tfstate_s3_bucket_name}" \
  -backend-config="key=${BACKEND_KEY}" \
  -backend-config="region=${TF_VAR_tfstate_bucket_region}"
terraform plan -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
terraform apply "$TF_MODULE.plan"
cd ${WORKING_DIRECTORY}


echo "#########################################################################################################"
set +e # Expected to fail when adding Route53 record due to invalid dns_domain
TF_MODULE="custom-ingress"
BACKEND_KEY="${TF_VAR_openshift_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
BACKEND_PATH="${TF_MODULE}"
TFVARS_FILE="../tfvars/${TF_VAR_business_unit}/${TF_VAR_aws_account}/${TF_VAR_cluster_name}.tfvars"
echo "=================================================="
echo "===========> Module - $TF_MODULE "
echo "=================================================="
cd "${TF_MODULE}"
rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true)
unset TF_WORKSPACE
terraform init \
  -backend-config="bucket=${TF_VAR_tfstate_s3_bucket_name}" \
  -backend-config="key=${BACKEND_KEY}" \
  -backend-config="region=${TF_VAR_tfstate_bucket_region}"
terraform plan -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
terraform apply "$TF_MODULE.plan"
cd ${WORKING_DIRECTORY}
set -e

echo "#########################################################################################################"
TF_MODULE="vault-k8s-auth"
BACKEND_KEY="${TF_VAR_openshift_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
BACKEND_PATH="${TF_MODULE}"
TFVARS_FILE="../tfvars/${TF_VAR_business_unit}/${TF_VAR_aws_account}/${TF_VAR_cluster_name}.tfvars"
echo "=================================================="
echo "===========> Module - $TF_MODULE "
echo "=================================================="
cd "${TF_MODULE}"
rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true)
unset TF_WORKSPACE
terraform init \
  -backend-config="bucket=${TF_VAR_tfstate_s3_bucket_name}" \
  -backend-config="key=${BACKEND_KEY}" \
  -backend-config="region=${TF_VAR_tfstate_bucket_region}"
terraform plan -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
terraform apply "$TF_MODULE.plan"
cd ${WORKING_DIRECTORY}

echo "#########################################################################################################"
TF_MODULE="acmhub-registration"
BACKEND_KEY="${TF_VAR_openshift_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
BACKEND_PATH="${TF_MODULE}"
TFVARS_FILE="../tfvars/${TF_VAR_business_unit}/${TF_VAR_aws_account}/${TF_VAR_cluster_name}.tfvars"
echo "=================================================="
echo "===========> Module - $TF_MODULE "
echo "=================================================="
cd "${TF_MODULE}"
rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true)
unset TF_WORKSPACE
terraform init \
  -backend-config="bucket=${TF_VAR_tfstate_s3_bucket_name}" \
  -backend-config="key=${BACKEND_KEY}" \
  -backend-config="region=${TF_VAR_tfstate_bucket_region}"
terraform plan -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
terraform apply "$TF_MODULE.plan"
cd ${WORKING_DIRECTORY}
