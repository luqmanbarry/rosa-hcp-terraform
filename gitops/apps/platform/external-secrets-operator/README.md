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

## Provider Examples

Example store definitions are in [`examples/`](./examples/README.md).

Included examples:

- AWS Secrets Manager
- Azure Key Vault
- Google Secret Manager
- HashiCorp Vault
- IBM Cloud Secrets Manager
- CyberArk Conjur

The CyberArk example uses the ESO `conjur` provider. That is the provider name you should expect in the store definition.

Use these examples to create central stores only.

Do not move normal application `ExternalSecret` objects into this chart. Keep those definitions with the consumer module that needs the secret.

The provider examples all use the same `ClusterSecretStore` name: `platform-secrets`.

That lets consumer modules reuse one global store name and avoid repeating provider-specific store names in every values file.

Consumer modules with secret examples:

- `identity-providers`
- `user-workload-monitoring`
- `cluster-logging`
- `splunk-log-forwarding`
- `oadp-operator`
