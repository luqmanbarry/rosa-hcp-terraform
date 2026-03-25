# ROSA HCP Factory

Reusable factory for building production-grade ROSA HCP clusters from Git-driven inputs.

The operating model is:

1. Engineers add or update cluster inputs under `clusters/`.
2. They open a pull request.
3. CI validates inputs, renders effective config, and validates Terraform.
4. Merge to `main` runs Terraform to create or update the cluster, register it to ACM, and bootstrap OpenShift GitOps.
5. OpenShift GitOps reconciles platform and workload configuration from Git.

## Start Here

- [Architecture Overview](./docs/architecture/platform-factory.md)
- [Terraform vs GitOps Boundary](./docs/architecture/terraform-vs-gitops-boundary.md)
- [Catalog](./catalog/README.md)
- [Clusters](./clusters/README.md)
- [Terraform Modules](./modules/README.md)
- [GitOps Apps](./gitops/apps/README.md)

## Repository Layout

- `catalog/`: reusable cluster classes and machine-pool classes
- `clusters/`: per-environment cluster instances and workload enablement
- `modules/`: reusable Terraform modules for cluster build and bootstrap
- `gitops/`: root app, platform apps, and workload apps
- `scripts/`: CI render, validation, and tool-check helpers
- `.github/workflows/`: CI/CD pipeline example

## Core Principles

- Terraform builds infrastructure and cluster bootstrap only.
- OpenShift GitOps owns steady-state day-2 configuration.
- Inputs are human-authored YAML.
- Rendered artifacts are machine-authored JSON.
- Cluster and workload differences are parameterized in Git, not hidden in scripts.

## Build Flow

```text
Engineer edits cluster YAML
  -> Pull request
  -> CI validate and render
  -> Review and approval
  -> Merge to main
  -> Terraform apply
     -> ROSA HCP cluster
     -> ACM registration
     -> OpenShift GitOps bootstrap
        -> Argo CD root app
           -> Platform apps
           -> Workload apps
```

## Terraform to GitOps Boundary

```text
Terraform
  - AWS discovery and prerequisites
  - ROSA HCP cluster
  - machine pools
  - ACM registration
  - OpenShift GitOps bootstrap

OpenShift GitOps
  - identity and RBAC
  - registry and ingress policy
  - monitoring and logging
  - OADP
  - AAP / CP4BA / OpenShift AI

Boundary
  Terraform stops after GitOps bootstrap.
  OpenShift GitOps owns steady-state cluster configuration after that point.
```

## Quick Start

1. Choose or create a cluster class under `catalog/cluster-classes/`.
2. Add a cluster instance under `clusters/<env>/<cluster-name>/`.
3. Define:
   - `cluster.yaml` for cluster and machine-pool inputs
   - `gitops.yaml` for platform and workload apps
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

Default behavior is safe:

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

## Audit Model

Git is the source of truth for human inputs.

CI should archive:

- `effective-config.json`
- `terraform.auto.tfvars.json`
- Terraform plan text and JSON
- Terraform outputs
- build metadata

These should be stored as CI artifacts or in immutable object storage.

## Current Status

This repository now uses the factory path only:

- `catalog/`
- `clusters/`
- `modules/`
- `gitops/`

The old stage-based Terraform pipeline and helper scripts have been removed.
