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
