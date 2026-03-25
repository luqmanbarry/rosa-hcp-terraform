# Terraform vs GitOps Boundary

Use this rule consistently:

- If the resource exists primarily in AWS, OCM, RHCS, or outside the cluster, use Terraform.
- If the resource is Kubernetes-native and should be continuously reconciled from Git, use OpenShift GitOps.

## Terraform-Owned

- S3 remote state
- VPC, subnets, Route53, IAM roles in scope
- ROSA HCP cluster
- ROSA machine pools
- machine pool autoscaling bounds
- ACM registration
- OpenShift GitOps bootstrap

## GitOps-Owned

- IDPs and OAuth
- groups and RBAC
- self-provisioner policy
- internal image registry configuration
- user workload monitoring
- image registry allow/deny policy
- cluster logging and monitoring config
- Vault or secret operator integration
- OADP operator, backups, and restores
- OpenShift Virtualization and MTV
- AAP, CP4BA, AI workloads

## Exception Handling

If a Kubernetes resource must exist before GitOps can bootstrap, keep only that minimum bootstrap path in Terraform and move steady-state ownership to GitOps afterward.

## Practical Examples

| Concern | Owner | Reason |
| --- | --- | --- |
| ROSA HCP cluster | Terraform | external RHCS/OCM resource |
| worker pools and autoscaling bounds | Terraform | capacity and node lifecycle |
| OpenShift GitOps operator bootstrap | Terraform | required before GitOps can reconcile |
| cluster OAuth and RBAC | GitOps | in-cluster, continuously reconciled |
| OADP schedules and restores | GitOps | day-2 operational policy |
| AAP / CP4BA / OpenShift AI | GitOps | workload lifecycle and configuration |
