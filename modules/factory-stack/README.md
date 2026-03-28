# factory-stack

This is the main Terraform module for one cluster.

It does these jobs:

- discovers the target VPC, subnets, and Route53 zone
- figures out which subnets are private and public
- creates the ROSA HCP cluster
- creates additional machine pools
- optionally registers the cluster to ACM
- optionally bootstraps OpenShift GitOps

## Key Inputs

- cluster name and environment data
- AWS region and network lookup inputs
- machine pools
- ACM kubeconfigs
- GitOps repo and overlay inputs

## Key Outputs

- cluster ID
- API URL
- console URL
- cluster domain
- current OpenShift version

## Notes

- machine pools can define autoscaling bounds and labels
- extra machine pools inherit profile defaults and can override labels and instance type
- if workload modules do not set selectors, workloads land on the default worker pool

## ACM And GitOps

If ACM registration is enabled, the cluster is registered to ACM as part of bootstrap.

That does not change the day-2 ownership model:

- ACM is optional and used for registration, visibility, and optional governance
- OpenShift GitOps still runs on the HCP cluster
- platform and workload apps still come from the HCP cluster's own Argo CD instance
