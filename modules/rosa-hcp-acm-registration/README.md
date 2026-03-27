# rosa-hcp-acm-registration

This module registers the cluster to ACM.

It does these jobs:

- creates `ManagedCluster`
- creates `KlusterletAddonConfig`
- retrieves ACM import manifests from the hub
- applies import manifests to the managed cluster

## Requirements

- kubeconfig for the managed cluster
- kubeconfig for the ACM hub cluster
- `oc` available in the execution environment

## Notes

- the module is idempotent across re-applies by hashing the applied manifest content
- this is still a bootstrap-style integration point
