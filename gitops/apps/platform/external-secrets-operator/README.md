# external-secrets-operator

Installs the External Secrets Operator early in the GitOps sync order.

## Default

- namespace: `external-secrets-operator`
- global `ClusterSecretStore` name: `platform-secrets`
- package: `external-secrets-operator`
- source: `community-operators`
- channel: `stable`
- install plan approval: `Automatic`

## Notes

- This chart installs only the operator lifecycle resources.
- Define `SecretStore` or `ClusterSecretStore` centrally.
- Let the modules that consume secrets define the `ExternalSecret` resources they need in their own values files.
- Before enabling a module that needs secrets, make sure the store exists and the module values file includes the matching `externalSecrets` entries.
- The default catalog settings are configurable because operator catalogs can vary by environment.
- For ROSA, the default shared secret backend example is AWS Secrets Manager through `external-secrets-config`.
- This chart is a foundational dependency, so it defaults to automatic approval to make the ESO CRDs available early.

## Provider Examples

Use [`external-secrets-config`](../external-secrets-config/README.md) for shared `ClusterSecretStore` definitions and provider examples.

Do not move normal application `ExternalSecret` objects into this chart. Keep those definitions with the consumer module that needs the secret.

Consumer modules with secret examples:

- `identity-providers`
- `user-workload-monitoring`
- `cluster-logging`
- `splunk-log-forwarding`
- `oadp-operator`
