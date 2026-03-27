# oadp-operator

Installs the OADP operator and can create a `DataProtectionApplication`.

## Default

- operator installed
- `DataProtectionApplication` disabled until real backup settings are supplied

## When Enabling the DPA

Provide:

- bucket
- credential secret
- region
- plugin and node-agent settings for your environment

If the credential `Secret` should be managed by External Secrets Operator, define the matching `ExternalSecret` in the same values file.

Examples:

- [`examples/secret-integration.values.example.yaml`](./examples/secret-integration.values.example.yaml)
- [`examples/externalsecrets.manifests.example.yaml`](./examples/externalsecrets.manifests.example.yaml)

HashiCorp Vault is the active default example. Other providers are included as commented alternatives.
