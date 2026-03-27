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
