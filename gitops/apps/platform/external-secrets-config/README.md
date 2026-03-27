# external-secrets-config

This module configures shared External Secrets Operator settings.

Use it for:

- `ExternalSecretsConfig`
- shared `ClusterSecretStore` objects
- one shared default `ClusterSecretStore` name for the cluster

Do not use this module as the normal place for app `ExternalSecret` objects.

Normal app secrets should stay with the app that uses them.

## Provider Examples

Provider example snippets are in:

- [examples/README.md](./examples/README.md)
- [examples/ibm-cloud-secrets-manager.yaml](./examples/ibm-cloud-secrets-manager.yaml)
- [examples/hashicorp-vault.yaml](./examples/hashicorp-vault.yaml)
- [examples/aws-secrets-manager.yaml](./examples/aws-secrets-manager.yaml)
- [examples/azure-key-vault.yaml](./examples/azure-key-vault.yaml)
- [examples/google-secret-manager.yaml](./examples/google-secret-manager.yaml)
- [examples/cyberark-conjur.yaml](./examples/cyberark-conjur.yaml)

Copy one example into `clusters/<env>/<cluster>/values/external-secrets-config.yaml` and replace the placeholder values.

HashiCorp Vault is the default example pattern used in the sample app values files.

The other provider examples are optional references you can copy if your platform uses a different backend.

Use one shared `ClusterSecretStore` name, such as `platform-secrets`, and make app `ExternalSecret` objects reference that same name.
