# External Secrets Examples

This folder keeps only the consumer `ExternalSecret` example for app teams.

Use them like this:

1. Create the shared `ClusterSecretStore` through `external-secrets-config`.
2. Keep `ExternalSecret` resources close to the module that uses the secret.

Important rule:

- this chart installs the operator
- shared provider and store examples now live under `external-secrets-config`
- the app that needs a Kubernetes `Secret` should define the matching `ExternalSecret` in its own values file

Files in this folder:

- `consumer-external-secret.example.yaml`

Recommended use:

- create one shared store from `external-secrets-config`
- let consumer modules such as `identity-providers`, `user-workload-monitoring`, `cluster-logging`, `splunk-log-forwarding`, and `oadp-operator` define their own `externalSecrets` entries
