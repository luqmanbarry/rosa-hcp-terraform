# Execution Models

This document explains how to run this repo in three common ways:

- from a bastion host
- from Ansible Automation Platform (AAP)
- from Terraform CLI in a CI runner

Use the same Git inputs in all cases:

- `clusters/<env>/<cluster>/cluster.yaml`
- `clusters/<env>/<cluster>/gitops.yaml`
- `clusters/<env>/<cluster>/values/*.yaml`

## Before You Run Anything

Make sure these items are ready:

- the cluster files are complete
- the needed values files exist for enabled GitOps apps
- required `ExternalSecret` entries are defined before you enable secret-consuming modules
- the runner has the required tools:
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

You can check the local tools with:

```bash
scripts/check_required_ci_tools.sh bash git jq python3 terraform helm rg oc
```

## Shared Flow

No matter where you run it, the normal flow is:

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

## Option 1: Run From A Bastion Host

This is the simplest manual way to run the repo.

1. Clone the repo to the bastion host.
2. Install the required tools.
3. Export the required credentials.
4. Validate and render the cluster inputs.
5. Run Terraform from the cluster directory.

Example:

```bash
export TF_VAR_ocm_token='your-ocm-token'
export AWS_PROFILE='your-aws-profile'

python3 scripts/validate_stack_inputs.py \
  --cluster clusters/dev/cluster-01/cluster.yaml \
  --gitops-values clusters/dev/cluster-01/gitops.yaml

python3 scripts/render_effective_config.py \
  --cluster clusters/dev/cluster-01/cluster.yaml \
  --gitops-values clusters/dev/cluster-01/gitops.yaml \
  --output-dir .artifacts/dev-cluster-01

cp .artifacts/dev-cluster-01/terraform.auto.tfvars.json \
  clusters/dev/cluster-01/terraform.auto.tfvars.json

terraform -chdir=clusters/dev/cluster-01 init
terraform -chdir=clusters/dev/cluster-01 plan
terraform -chdir=clusters/dev/cluster-01 apply
```

Use this model when:

- you want a controlled manual run
- the bastion host already has network access to AWS, ROSA, and Git
- you want to debug a single cluster build directly

## Option 2: Run From AAP

Use AAP as the orchestration layer, and run the same repo commands inside a job template or workflow template.

Best practice:

- keep Git as the source of truth
- let AAP clone the repo at the approved commit or branch
- pass secrets as AAP credentials or extra vars
- call the same validation, render, and Terraform steps used by CI

Recommended AAP job flow:

1. Checkout repo.
2. Install or verify required tools in the execution environment.
3. Validate cluster files.
4. Render `terraform.auto.tfvars.json`.
5. Run `terraform init`.
6. Run `terraform plan`.
7. Add an approval step if needed.
8. Run `terraform apply`.

Simple command sequence for an AAP job:

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

terraform -chdir="$CLUSTER_DIR" init
terraform -chdir="$CLUSTER_DIR" plan
terraform -chdir="$CLUSTER_DIR" apply
```

Useful AAP extra vars:

```yaml
cluster_dir: clusters/dev/cluster-01
artifact_dir: /runner/artifacts/dev-cluster-01
```

Use this model when:

- you want approvals in AAP
- you want RBAC and credential control in AAP
- you want a standard execution path for ops teams

## Option 3: Run From Terraform In CI

This repo already includes a GitHub Actions example in [factory.yml](../../.github/workflows/factory.yml).

The current example does this:

- PR:
  - validates changed clusters
  - renders effective config
  - runs `terraform validate`
- merge to `main`:
  - validates changed clusters
  - renders effective config
  - prepares the stack for `plan` and `apply`

The example apply stage is still a placeholder, so you must finish the backend and apply steps for your environment.

The normal CI pattern should be:

1. detect changed cluster directories
2. validate each changed cluster
3. render `terraform.auto.tfvars.json`
4. run `terraform init`
5. run `terraform plan`
6. store plan and render artifacts
7. after approval, run `terraform apply`

Use this model when:

- you want PR-driven delivery
- you want audit artifacts for every run
- you want merge-to-main to be the deployment trigger

## Which Model Should You Choose

Use:

- bastion host for manual testing and debugging
- AAP for controlled operations with approvals
- CI for the normal production workflow

For most teams, the best long-term pattern is:

```text
Engineers change Git
  -> PR validation in CI
  -> approval
  -> apply from CI or AAP
```

## Notes

- `terraform.auto.tfvars.json` is generated. Do not hand-edit it.
- Terraform builds the cluster and bootstraps OpenShift GitOps.
- OpenShift GitOps owns the selected platform and workload modules after bootstrap.
- If ACM registration is enabled for a class, make sure the ACM inputs are also ready before apply.
