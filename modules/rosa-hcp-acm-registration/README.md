# rosa-hcp-acm-registration

This module registers the cluster to ACM.

It is opt-in. The factory does not execute this module unless ACM registration is enabled and both kubeconfig paths are provided.

It does these jobs:

- creates `ManagedCluster`
- creates `KlusterletAddonConfig`
- retrieves ACM import manifests from the hub
- applies import manifests to the managed cluster

This module does not hand application delivery to ACM.

The intended model is:

- Terraform registers the cluster to ACM
- Terraform bootstraps OpenShift GitOps on the HCP cluster
- the HCP cluster keeps its own Argo CD for platform and workload delivery

Use ACM here for registration, visibility, and optional governance. Do not treat ACM as the default GitOps owner for this repo.

## Requirements

- kubeconfig for the managed cluster
- kubeconfig for the ACM hub cluster
- `oc` available in the execution environment

## Notes

- the module is idempotent across re-applies by hashing the applied manifest content
- the module waits for the ACM import secret from the hub instead of using a fixed sleep
- this is still a bootstrap-style integration point
