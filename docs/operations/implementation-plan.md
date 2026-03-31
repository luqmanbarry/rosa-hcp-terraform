# Day Plan For ROSA HCP Factory

This repo follows the same factory shape used by the Classic repo, but it stays specific to ROSA HCP.

The plan below keeps the work split into clear phases so the repo stays usable while it grows.

## Day 0

- keep the factory layout consistent:
  - `catalog/`
  - `clusters/`
  - `modules/`
  - `gitops/`
  - `docs/`
  - `scripts/`
- keep cluster inputs in Git and reusable logic in shared modules
- document the customer-managed AWS foundation requirement clearly
- keep Terraform and GitOps ownership boundaries simple

## Day 1

- build ROSA HCP clusters from `clusters/<group-path>/<name>/`
- support worker machine pools and autoscaling
- keep ACM registration optional
- keep workload identity optional
- bootstrap OpenShift GitOps after cluster creation

## Day 2

- manage platform and workload apps through the shared GitOps overlay
- keep admin GitOps separate from tenant app CD
- keep secrets out of Git and use AWS Secrets Manager through External Secrets Operator by default
- expand optional modules only when they are valid for ROSA HCP

## Ongoing Rules

- do not add Classic-only infrastructure patterns that do not fit ROSA HCP
- do not move day-2 ownership from cluster-local GitOps to ACM
- keep optional features opt-in
- keep docs in simple English
