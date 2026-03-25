# rosa-hcp-acm-registration

Registers the managed cluster to ACM by creating hub-side resources and applying the import manifests to the managed cluster.

## Responsibilities

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
- this remains a bootstrap-oriented integration point and is a candidate for future ACM-native refinement
