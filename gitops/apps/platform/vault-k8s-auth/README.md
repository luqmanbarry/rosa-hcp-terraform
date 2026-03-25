# vault-k8s-auth

Bootstraps Kubernetes-side resources for Vault Kubernetes authentication.

## Responsibilities

- namespace
- service account
- `system:auth-delegator` binding
- optional legacy reviewer-token secret

## Default

- legacy reviewer-token secret disabled

## Notes

This chart does not configure the Vault-side auth backend or roles. That integration remains environment-specific.
