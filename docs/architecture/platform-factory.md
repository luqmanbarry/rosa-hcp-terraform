# Platform Factory

This repo is a reusable way to build ROSA HCP clusters from files stored in Git.

It does not create the whole AWS foundation from zero. The customer is expected to provide the VPC, subnets, Route53 zone, and other shared network prerequisites first.

Simple flow:

1. Users propose cluster inputs in Git.
2. A pull request is reviewed and approved.
3. CI validates and renders the effective configuration.
4. Merge to `main` runs Terraform to:
   - discover the customer-provided AWS foundation
   - create the ROSA HCP cluster
   - optionally register the cluster to ACM
   - optionally create workload identity IAM roles
   - bootstrap OpenShift GitOps
5. OpenShift GitOps applies the platform and workload apps.

If ACM registration is enabled, the cluster is added to ACM for fleet visibility and optional policy use. GitOps still stays on the HCP cluster itself.

This repo is customer-neutral. Product names such as `cp4ba`, `aap`, `oadp`, and `mtv` are used only when they describe real reusable modules.

## End-to-End Flow

```text
Cluster class
  + cluster files
  -> render effective config
  -> Terraform modules
     -> ROSA HCP cluster
     -> optional ACM registration
     -> optional workload identity IAM roles
     -> OpenShift GitOps bootstrap
        -> root app
           -> platform apps
           -> workload apps
```

## Terraform Scope

Terraform only handles build and bootstrap work:

- remote state
- discovery of the customer-provided AWS network and DNS baseline
- ROSA HCP cluster creation
- base machine pools
- optional ACM registration
- optional workload identity IAM roles
- OpenShift GitOps bootstrap

ACM does not replace the cluster-local GitOps model in this repo.

## GitOps Scope

OpenShift GitOps handles normal cluster configuration after bootstrap:

- identity providers
- RBAC
- logging and monitoring
- backup and restore
- secrets integration
- ingress and registry policies
- OpenShift Virtualization and MTV
- workload onboarding

## Repository Layout

- `catalog/`: shared defaults for clusters and machine pools
- `clusters/`: one folder per cluster
- `modules/`: reusable Terraform modules
- `gitops/`: bootstrap, shared overlay, platform apps, and workload apps
- `scripts/`: helper scripts used by CI

## Engineer Workflow

```text
Engineer
  -> edit files in clusters/
  -> open pull request

CI pipeline
  -> validate inputs
  -> render effective config
  -> run Terraform validation

After merge
  -> Terraform creates or updates the cluster
  -> Terraform creates the GitOps root app
  -> OpenShift GitOps applies the selected apps
```

For run methods such as a bastion host, AAP, or CI, see [Execution Models](../operations/execution-models.md).

## Audit Model

Git is the source of truth.

People should edit YAML files. CI should generate JSON artifacts.

CI should save audit artifacts such as:

- effective config
- Terraform plan text and JSON
- provider/module versions
- outputs
- build metadata
