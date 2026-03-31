# rosa-hcp-workload-identity

This module creates AWS IAM roles for workload identity on ROSA HCP.

Use it when:

- the cluster already uses STS and OIDC
- you want Terraform to manage the AWS IAM side
- GitOps will manage the Kubernetes service accounts and annotations

What it does:

- creates one IAM role per workload definition
- creates the trust policy for one Kubernetes service account per role
- optionally attaches AWS managed policies
- optionally adds one inline policy per role

What it does not do:

- it does not annotate service accounts in the cluster
- it does not create Kubernetes service accounts

Use the `workload-identity-serviceaccounts` GitOps chart for the in-cluster side.

This module is opt-in. The factory does not execute it unless `workload_identity.enabled` is true and the required OIDC inputs are set.
