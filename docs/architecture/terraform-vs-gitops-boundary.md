# Terraform vs GitOps Boundary

Use this simple rule:

- If the resource lives outside the cluster, use Terraform.
- If the resource lives inside the cluster and should stay in sync from Git, use OpenShift GitOps.

## Terraform-Owned

- S3 remote state
- VPC, subnets, Route53, and IAM roles that this repo manages
- ROSA HCP cluster
- ROSA machine pools
- machine pool autoscaling bounds
- optional ACM registration
- OpenShift GitOps bootstrap

## GitOps-Owned

- IDPs and OAuth
- groups and RBAC
- self-provisioner policy
- internal image registry configuration
- user workload monitoring
- image registry allow/deny policy
- cluster logging and monitoring config
- AWS Secrets Manager or other secret operator integration
- OADP operator, backups, and restores
- OpenShift Virtualization and MTV
- AAP, CP4BA, AI workloads

## Exception Handling

If something inside the cluster must exist before GitOps can start, keep only that small bootstrap step in Terraform. After that, move ownership to GitOps.

## Practical Examples

- ROSA HCP cluster: Terraform
  Reason: the cluster is created through RHCS/OCM, not as a normal Kubernetes object
- worker pools and autoscaling bounds: Terraform
  Reason: this is cluster capacity and node lifecycle
- OpenShift GitOps bootstrap: Terraform
  Reason: GitOps must exist before GitOps can manage anything
- ACM registration: Terraform
  Reason: registration is bootstrap work and should happen before any optional hub-side governance
- cluster OAuth and RBAC: GitOps
  Reason: these are in-cluster settings that should stay in sync from Git
- OADP schedules and restores: GitOps
  Reason: these are day-2 operations and policies
- AAP, CP4BA, and OpenShift AI: GitOps
  Reason: these are workloads that run on the cluster

Even when ACM registration is enabled, this repo keeps OpenShift GitOps local to the HCP cluster. ACM is not the normal app delivery path here.
