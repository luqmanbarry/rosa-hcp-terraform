# external-secrets-operator

Installs the External Secrets Operator early in the GitOps sync order.

## Default

- namespace: `external-secrets-operator`
- package: `external-secrets-operator`
- source: `community-operators`
- channel: `stable`
- install plan approval: `Automatic`

## Notes

- This chart installs only the operator lifecycle resources.
- Define `SecretStore`, `ClusterSecretStore`, and `ExternalSecret` resources in separate GitOps modules or workload charts.
- The default catalog settings are configurable because operator catalogs can vary by environment.
