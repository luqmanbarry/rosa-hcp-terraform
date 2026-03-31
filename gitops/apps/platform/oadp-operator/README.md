# oadp-operator

Installs the OADP operator and can create a `DataProtectionApplication`.

## Default

- operator installed
- install plan approval set to `Automatic`
- `DataProtectionApplication` disabled until real backup settings are supplied

## When Enabling the DPA

Provide:

- bucket
- credential secret
- region
- plugin and node-agent settings for your environment

If the credential `Secret` should be managed by External Secrets Operator, define the matching `ExternalSecret` in the same values file.

The operator uses automatic approval by default because `oadp-backup` and `oadp-restore` depend on the OADP APIs.

Examples:

- [`examples/secret-integration.values.example.yaml`](./examples/secret-integration.values.example.yaml)
- [`examples/externalsecrets.manifests.example.yaml`](./examples/externalsecrets.manifests.example.yaml)

AWS Secrets Manager is the active default example for ROSA. Other providers are included as commented alternatives.
