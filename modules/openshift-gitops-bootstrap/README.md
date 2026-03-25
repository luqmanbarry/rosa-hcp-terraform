# openshift-gitops-bootstrap

Bootstraps OpenShift GitOps and seeds the root `Application`.

## Responsibilities

- creates GitOps namespaces
- installs the OpenShift GitOps operator
- waits for operator and Argo CD readiness
- optionally creates a repository secret
- creates the root `Application`

## Requirements

- kubeconfig for the managed cluster
- `oc` available in the execution environment

## Root App Contract

The root app points to an environment overlay under `gitops/overlays/` and injects:

- Git repository URL
- target revision
- stack-owned values object from `gitops.yaml`

## Notes

- readiness is handled with `oc wait`, not fixed sleeps
- if no private repo credentials are supplied, the module assumes the repo is reachable without them
