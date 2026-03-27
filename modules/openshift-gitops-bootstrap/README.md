# openshift-gitops-bootstrap

This module installs OpenShift GitOps and creates the root Argo CD application.

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

The root app points to `gitops/overlays/cluster-applications/` and passes in:

- Git repository URL
- target revision
- cluster-owned values from `gitops.yaml`

## Notes

- readiness uses `oc wait`
- if no private repo credentials are supplied, the module assumes the repo is public or otherwise reachable
