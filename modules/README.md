# Terraform Modules

These are the main Terraform modules used by this repo.

## Module Index

- [factory-stack](./factory-stack/README.md): main module that calls the other modules
- [rosa-hcp-core](./rosa-hcp-core/README.md): creates the ROSA HCP cluster
- [rosa-hcp-machine-pools](./rosa-hcp-machine-pools/README.md): creates additional ROSA machine pools
- [rosa-hcp-acm-registration](./rosa-hcp-acm-registration/README.md): registers the cluster to ACM
- [rosa-hcp-workload-identity](./rosa-hcp-workload-identity/README.md): creates opt-in IAM roles for workload identity
- [openshift-gitops-bootstrap](./openshift-gitops-bootstrap/README.md): installs OpenShift GitOps and creates the root app

## Execution Order

```text
factory-stack
  -> rosa-hcp-core
  -> rosa-hcp-machine-pools
  -> rosa-hcp-acm-registration
  -> rosa-hcp-workload-identity
  -> openshift-gitops-bootstrap
```
