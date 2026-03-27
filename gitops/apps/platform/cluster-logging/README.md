# cluster-logging

Installs the logging operator and can configure log forwarding.

## Responsibilities

- installs the operator
- creates collector service account and RBAC
- optionally creates `ClusterLogForwarder`

## Default

- operator installed
- forwarding disabled until a real destination is configured

## Required Inputs When Enabling Forwarding

- destination URL
- secret containing authentication token

If forwarding needs a token `Secret`, define the matching `ExternalSecret` in the same values file.

If you forward logs to Splunk, prefer the dedicated `splunk-log-forwarding` chart.

Examples:

- [`examples/secret-integration.values.example.yaml`](./examples/secret-integration.values.example.yaml)
- [`examples/externalsecrets.manifests.example.yaml`](./examples/externalsecrets.manifests.example.yaml)

HashiCorp Vault is the active default example. Other providers are included as commented alternatives.
