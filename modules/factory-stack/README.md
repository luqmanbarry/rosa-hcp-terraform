# factory-stack

Composes the Terraform modules used by each environment stack root.

## Responsibilities

- discovers the target VPC, subnets, and Route53 zone
- derives private and public subnet sets
- creates the ROSA HCP cluster
- creates additional machine pools
- optionally registers the cluster to ACM
- optionally bootstraps OpenShift GitOps

## Key Inputs

- cluster identity and environment metadata
- AWS region and network lookup inputs
- machine pools
- ACM bootstrap kubeconfigs
- GitOps repository and overlay inputs

## Key Outputs

- cluster ID
- API URL
- console URL
- cluster domain
- current OpenShift version

## Notes

- machine pools can define autoscaling bounds and labels
- additional machine pools inherit profile defaults and can override labels and instance type
- if workload modules do not set selectors, workloads land on the default worker pool
