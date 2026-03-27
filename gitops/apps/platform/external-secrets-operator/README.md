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
- Define `SecretStore` or `ClusterSecretStore` centrally.
- Let the modules that consume secrets define the `ExternalSecret` resources they need in their own values files.
- The default catalog settings are configurable because operator catalogs can vary by environment.
