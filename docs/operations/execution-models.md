# Execution Models

This document explains five common ways to run this ROSA HCP repo:

- GitHub Actions
- Azure Pipelines
- bastion host
- Ansible Automation Platform (AAP)
- Terraform CLI

All five patterns use the same Git input files:

- `clusters/<group-path>/<cluster>/cluster.yaml`
- `clusters/<group-path>/<cluster>/gitops.yaml`
- `clusters/<group-path>/<cluster>/values/*.yaml`

Reusable execution files in this repo:

- [run_cluster_workflow.sh](../../scripts/run_cluster_workflow.sh)
- [run_cluster_workflow_bastion.sh](../../scripts/run_cluster_workflow_bastion.sh)
- [factory.yml](../../.github/workflows/factory.yml)
- [azure-pipelines.yml](../../azure-pipelines.yml)
- [aap-run-factory.yml](../../playbooks/aap-run-factory.yml)
- [aap-execution.example.yml](./aap-execution.example.yml)

## Shared Requirements

These items must be ready no matter where you run the code:

- the cluster files are complete
- values files exist for every GitOps app you enable
- required `externalSecrets` entries are defined before you enable secret-consuming modules
- the execution environment has these tools:
  - `bash`
  - `git`
  - `jq`
  - `python3`
  - `terraform`
  - `helm`
  - `rg`
  - `oc`
- you have AWS access for Terraform
- you have a valid ROSA/OCM token
- you have access to the GitOps repo if it is private

Tool check:

```bash
scripts/check_required_ci_tools.sh bash git jq python3 terraform helm rg oc
```

Common execution flow:

```text
Validate cluster files
  -> render effective config
  -> write terraform.auto.tfvars.json
  -> terraform init
  -> terraform plan
  -> terraform apply
```

Example cluster path used below:

```text
clusters/dev/cluster-01
```

## Pattern 1: GitHub Actions

Use this pattern when GitHub is your source control and deployment runner.

### Setup Prerequisites

- GitHub repository with Actions enabled
- GitHub Actions runners with network access to AWS, ROSA, and Git
- required repository secrets such as:
  - `OCM_TOKEN`
  - AWS credentials or role assumption inputs
  - private GitOps repo credentials if needed
- backend configuration and apply gates added to the workflow

### How It Works

This repo already includes a GitHub Actions example in [factory.yml](../../.github/workflows/factory.yml).

Current behavior:

- pull request:
  - detects changed clusters
  - validates inputs
  - renders effective config
  - runs `terraform validate`
- merge to `main`:
  - detects changed clusters
  - validates inputs
  - renders effective config
  - prepares stack roots for `plan` and `apply`

Important note:

- the current apply stage is still a placeholder
- you still need to wire the backend, plan storage, approval gates, and `terraform apply`

### Recommended Flow

1. Detect changed cluster directories.
2. Validate each changed cluster.
3. Render `terraform.auto.tfvars.json`.
4. Run `terraform init`.
5. Run `terraform plan`.
6. Save the plan and rendered artifacts.
7. After approval, run `terraform apply`.

Use the shared runner script in custom GitHub jobs:

```bash
scripts/run_cluster_workflow.sh \
  --cluster-dir clusters/dev/cluster-01 \
  --artifact-dir .artifacts/github/dev-cluster-01 \
  --mode plan \
  --backend false
```

## Pattern 2: Azure Pipelines

Use this pattern when Azure DevOps is your source control or approved enterprise runner.

### Setup Prerequisites

- Azure DevOps project and pipeline
- Microsoft-hosted or self-hosted agents with network access to AWS, ROSA, and Git
- secure pipeline variables or variable groups for:
  - `OCM_TOKEN`
  - AWS credentials
  - private GitOps repo credentials if needed
- a pipeline stage for validation
- a pipeline stage for plan
- a pipeline approval gate before apply

### Recommended Flow

1. Checkout the repo.
2. Install or verify the required tools.
3. Run input validation.
4. Render `terraform.auto.tfvars.json`.
5. Run `terraform init`.
6. Run `terraform plan`.
7. Publish plan and render artifacts.
8. Run `terraform apply` only after approval.

This repo includes an Azure Pipelines example at [azure-pipelines.yml](../../azure-pipelines.yml).

### Command Sequence

```bash
scripts/check_required_ci_tools.sh bash git jq python3 terraform helm rg oc

python3 scripts/validate_stack_inputs.py \
  --cluster "$CLUSTER_DIR/cluster.yaml" \
  --gitops-values "$CLUSTER_DIR/gitops.yaml"

python3 scripts/render_effective_config.py \
  --cluster "$CLUSTER_DIR/cluster.yaml" \
  --gitops-values "$CLUSTER_DIR/gitops.yaml" \
  --output-dir "$ARTIFACT_DIR"

cp "$ARTIFACT_DIR/terraform.auto.tfvars.json" \
  "$CLUSTER_DIR/terraform.auto.tfvars.json"

scripts/run_cluster_workflow.sh \
  --cluster-dir "$CLUSTER_DIR" \
  --artifact-dir "$ARTIFACT_DIR" \
  --mode apply \
  --backend true
```

## Pattern 3: Bastion Host

Use this pattern for manual admin execution and debugging.

### Setup Prerequisites

- bastion host with network access to AWS, ROSA, and Git
- repo cloned on the bastion host
- required tools installed
- ROSA and AWS credentials exported or available through the local auth model
- filesystem access to store temporary artifacts such as `.artifacts/`

### Command Sequence

```bash
chmod +x scripts/run_cluster_workflow_bastion.sh

export TF_VAR_ocm_token='your-ocm-token'
export AWS_PROFILE='your-aws-profile'

scripts/run_cluster_workflow_bastion.sh \
  --cluster-dir clusters/dev/cluster-01 \
  --artifact-dir .artifacts/dev-cluster-01 \
  --mode apply \
  --backend-false
```

Use this when:

- you want a controlled manual run
- you want to debug one cluster directly

## Pattern 4: AAP

Use this pattern when your ops team wants approvals, RBAC, and controlled credentials in AAP.

### Setup Prerequisites

- AAP controller and execution environment
- execution environment image with the required tools installed
- repository access from AAP
- AAP credentials for:
  - Git
  - AWS
  - `OCM_TOKEN`
- job template or workflow template
- optional approval node before apply

### Recommended AAP Job Flow

1. Checkout the repo.
2. Check the required tools.
3. Validate cluster files.
4. Render `terraform.auto.tfvars.json`.
5. Run `terraform init`.
6. Run `terraform plan`.
7. Add approval if needed.
8. Run `terraform apply`.

This repo includes an AAP playbook example at [aap-run-factory.yml](../../playbooks/aap-run-factory.yml).

### Command Sequence

```bash
ansible-playbook playbooks/aap-run-factory.yml \
  -e @docs/operations/aap-execution.example.yml \
  -e cluster_dir="$CLUSTER_DIR" \
  -e artifact_dir="$ARTIFACT_DIR" \
  -e workflow_mode=apply \
  -e terraform_backend=true
```

Useful AAP extra vars:

```yaml
cluster_dir: clusters/dev/cluster-01
artifact_dir: /runner/artifacts/dev-cluster-01
workflow_mode: plan
terraform_backend: false
```

## Pattern 5: Terraform CLI

Use this pattern when you want to run the repo directly with Terraform from any approved shell environment.

### Setup Prerequisites

- local or remote shell with the required tools
- Terraform backend settings ready if you use a remote backend
- required environment variables exported
- network access to AWS, ROSA, and Git

### Command Sequence

```bash
chmod +x scripts/run_cluster_workflow.sh

export TF_VAR_ocm_token='your-ocm-token'
export AWS_PROFILE='your-aws-profile'

scripts/run_cluster_workflow.sh \
  --cluster-dir clusters/dev/cluster-01 \
  --artifact-dir .artifacts/dev-cluster-01 \
  --mode apply \
  --backend true
```

## Which Pattern Should You Choose

Use:

- GitHub Actions for GitHub-native PR and merge workflows
- Azure Pipelines for Azure DevOps-native enterprise pipelines
- bastion host for manual testing and debugging
- AAP for controlled operations with approvals
- Terraform CLI for direct shell execution

For most teams, the long-term production pattern should be:

```text
Engineers change Git
  -> PR validation in GitHub Actions or Azure Pipelines
  -> approval
  -> apply from CI, AAP, or an approved admin-run path
```

## Notes

- `terraform.auto.tfvars.json` is generated. Do not hand-edit it.
- Terraform builds the cluster and bootstraps OpenShift GitOps.
- OpenShift GitOps owns the selected platform and workload modules after bootstrap.
- If ACM registration is enabled for a class, make sure the ACM inputs are also ready before apply.
