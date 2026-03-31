# workload-identity-serviceaccounts

This chart manages the Kubernetes side of workload identity for ROSA.

Use it together with the Terraform `rosa-hcp-workload-identity` module.

Split of ownership:

- Terraform creates the AWS IAM roles and trust policies
- this chart creates the Kubernetes service accounts and annotations

Default annotation pattern:

- `eks.amazonaws.com/role-arn: arn:aws:iam::<account_id>:role/<role_name>`

This chart is opt-in. It renders nothing until you add `serviceAccounts` entries in the cluster values file and enable the app in `gitops.yaml`.

Use a real admin namespace such as `openshift-config` for the Argo CD application that points to this chart. Do not target the `default` namespace.
