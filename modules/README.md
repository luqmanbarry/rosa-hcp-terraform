# Terraform Modules

These modules are the reusable Terraform building blocks for the factory.

## Module Index

- [factory-stack](./factory-stack/README.md): top-level composition module used by environment stack roots
- [rosa-hcp-core](./rosa-hcp-core/README.md): creates the ROSA HCP cluster
- [rosa-hcp-machine-pools](./rosa-hcp-machine-pools/README.md): creates additional ROSA machine pools
- [rosa-hcp-acm-registration](./rosa-hcp-acm-registration/README.md): registers the managed cluster to ACM
- [openshift-gitops-bootstrap](./openshift-gitops-bootstrap/README.md): installs GitOps bootstrap resources and seeds the root app

## Execution Order

```text
factory-stack
  -> rosa-hcp-core
  -> rosa-hcp-machine-pools
  -> rosa-hcp-acm-registration
  -> openshift-gitops-bootstrap
```
