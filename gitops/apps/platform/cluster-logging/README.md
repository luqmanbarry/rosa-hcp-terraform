# cluster-logging

Installs the logging operator and can configure log forwarding.

## Responsibilities

- installs the operator
- creates collector service account and RBAC
- optionally creates `ClusterLogForwarder`

## Default

- operator installed
- install plan approval set to `Automatic`
- forwarding disabled until a real destination is configured

## Required Inputs When Enabling Forwarding

- destination URL
- secret containing authentication token

If forwarding needs a token `Secret`, define the matching `ExternalSecret` in the same values file.

The operator uses automatic approval by default because other logging modules, such as `splunk-log-forwarding`, depend on the logging CRDs being present.

If you forward logs to Splunk, prefer the dedicated `splunk-log-forwarding` chart.

Examples:

- [`examples/secret-integration.values.example.yaml`](./examples/secret-integration.values.example.yaml)
- [`examples/externalsecrets.manifests.example.yaml`](./examples/externalsecrets.manifests.example.yaml)

AWS Secrets Manager is the active default example for ROSA. Other providers are included as commented alternatives.
