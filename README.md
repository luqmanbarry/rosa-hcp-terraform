# ROSA HCP Factory

This repo builds ROSA HCP clusters from files stored in Git.

It expects the customer to provision the AWS foundation first, including the VPC, subnets, Route53 zone, and any shared network prerequisites.

High-level flow:

1. Engineers add or update cluster inputs under `clusters/`.
2. They open a pull request.
3. CI validates inputs, renders effective config, and validates Terraform.
4. Merge to `main` runs Terraform to create or update the cluster, optionally register it to ACM if you enable that path, and bootstrap OpenShift GitOps.
5. OpenShift GitOps reconciles platform and workload configuration from Git.

If ACM registration is enabled, ACM is used for cluster inventory and optional governance. The HCP cluster still keeps its own OpenShift GitOps instance and manages its own day-2 configuration locally. ACM registration is opt-in and does not run by default.

## Start Here

- [Architecture Overview](./docs/architecture/platform-factory.md)
- [Terraform vs GitOps Boundary](./docs/architecture/terraform-vs-gitops-boundary.md)
- [Catalog](./catalog/README.md)
- [Clusters](./clusters/README.md)
- [Terraform Modules](./modules/README.md)
- [GitOps Apps](./gitops/apps/README.md)
- [Tenant Onboarding](./docs/operations/tenant-onboarding.md)
- [Execution Models](./docs/operations/execution-models.md)
- [Implementation Plan](./docs/operations/implementation-plan.md)
- [AAP Playbooks](./playbooks/README.md)

## Repository Layout

- `catalog/`: shared defaults, such as cluster classes and machine pool classes
- `clusters/`: one folder per cluster under `clusters/<group-path>/<name>/`, including GitOps app choices and values files
- `modules/`: Terraform modules that build the cluster and bootstrap GitOps
- `gitops/`: GitOps bootstrap, shared overlay, platform apps, and workload apps
- `scripts/`: validation and helper scripts used by CI
- `.github/workflows/`: CI/CD pipeline example
- `playbooks/`: example AAP execution playbooks
- `azure-pipelines.yml`: Azure Pipelines example

## Core Principles

- Terraform handles cluster build plus optional bootstrap integrations such as ACM registration and workload identity IAM roles.
- The customer provides the AWS foundation. This repo consumes it.
- Optional workload identity uses a split model: Terraform owns AWS IAM and GitOps owns service accounts.
- OpenShift GitOps owns normal day-2 cluster configuration.
- Inputs are human-authored YAML.
- Rendered artifacts are machine-authored JSON.
- Cluster differences live in Git, not in hidden shell logic.

## Prerequisites

Prepare these items before you start:

- Red Hat and ROSA access:
  - a Red Hat organization with ROSA HCP entitlement
  - an OCM offline token for the automation identity
- AWS access and baseline:
  - target AWS account and region
  - VPC and subnets already provisioned, or discoverable by the tags used in `cluster.yaml`
  - Route53 zone already provisioned for the cluster base domain
  - enough AWS quota for the machine pools you plan to use
  - AWS credentials or role assumption available to CI
- GitOps target repo:
  - reachable Git repository URL
  - target branch or revision
  - credentials if the repo is private
- CI/CD secrets and runtime inputs:
  - `OCM_TOKEN`
  - AWS authentication for Terraform
  - GitOps repo credentials if needed
  - access that lets Terraform install OpenShift GitOps on the cluster
  - ACM hub kubeconfig if you still enable ACM registration
- Cluster design inputs:
  - a cluster class exists under `catalog/cluster-classes/`
  - `clusters/<group-path>/<cluster-name>/cluster.yaml` is filled in
  - `clusters/<group-path>/<cluster-name>/gitops.yaml` is filled in
  - values files exist for the GitOps apps you want to enable
  - machine pool sizes, autoscaling settings, and labels are agreed before merge
- Optional integrations, if enabled in GitOps:
  - OADP bucket and credentials
  - identity provider details
  - RBAC group mappings
  - logging/monitoring endpoints and secrets
  - AWS Secrets Manager inputs if you use the default ROSA secret pattern
  - another secret backend only if you intentionally choose something other than the default
  - workload identity inputs if you opt into IAM roles for service accounts
  - `SecretStore` or `ClusterSecretStore` for any module that uses External Secrets Operator
  - matching `ExternalSecret` entries in the enabled module values files for any Kubernetes `Secret` that module needs

## How A Build Works

```text
Engineer edits files in clusters/
  -> Pull request
  -> CI validates and renders config
  -> Review and approval
  -> Merge to main
  -> Terraform apply
     -> ROSA HCP cluster
     -> optional ACM registration
     -> OpenShift GitOps bootstrap
        -> Argo CD root app
           -> Platform apps
           -> Workload apps
```

## What Terraform Does And What GitOps Does

```text
Terraform
  - AWS discovery and bootstrap prerequisites
  - ROSA HCP cluster
  - machine pools
  - optional ACM registration
  - optional workload identity IAM roles
  - OpenShift GitOps bootstrap

OpenShift GitOps
  - identity and RBAC
  - registry and ingress policy
  - monitoring and logging
  - OADP
  - AAP / CP4BA / OpenShift AI

Boundary
  Terraform stops after GitOps bootstrap.
  OpenShift GitOps owns cluster configuration after that point.
  ACM registration, if enabled, does not change GitOps ownership.
```

## Quick Start

1. Choose or create a cluster class under `catalog/cluster-classes/`.
2. Add a cluster instance under `clusters/<group-path>/<cluster-name>/`.
3. Define:
   - `cluster.yaml` for cluster and machine pool inputs
   - `gitops.yaml` for GitOps app selection
   - values files under `values/` for the apps you enable
   - if an enabled app needs a Kubernetes `Secret`, define its `externalSecrets` entries in that same values file before merge
4. Open a PR.
5. Review rendered config and Terraform validation in CI.
6. Merge to `main`.

## Dynamic Worker Pools

Machine pools are defined in `cluster.yaml`.

You can:

- add dedicated pools for workloads such as `aap` or `ai`
- set autoscaling bounds per pool
- attach identifying labels
- target those pools from workload modules with selectors

Default behavior:

- if a workload module does not set selectors, it lands on the default worker pool
- dedicated pools are only used when a workload explicitly opts into them

## CI/CD Requirements

The example pipeline checks for these tools before proceeding:

- `bash`
- `git`
- `jq`
- `python3`
- `terraform`
- `helm`
- `rg`
- `oc`

See [factory.yml](./.github/workflows/factory.yml) and [check_required_ci_tools.sh](./scripts/check_required_ci_tools.sh).

For step-by-step execution examples, see [Execution Models](./docs/operations/execution-models.md).

Users still need to prepare the environment before opening a PR. CI checks file structure and rendering, but it does not create missing AWS, ROSA, DNS, or external service prerequisites for you.
This includes the AWS foundation itself.

## Audit Model

Git is the source of truth for user-managed input files.

CI should archive:

- `effective-config.json`
- `terraform.auto.tfvars.json`
- Terraform plan text and JSON
- Terraform outputs
- build metadata

These should be stored as CI artifacts or in immutable object storage.

---
