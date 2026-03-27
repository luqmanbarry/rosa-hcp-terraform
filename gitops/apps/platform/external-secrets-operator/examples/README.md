# External Secrets Examples

These files are examples for the store side of External Secrets Operator.

Use them like this:

1. Pick one provider example and create a central `SecretStore` or `ClusterSecretStore`.
2. Do not copy all provider examples into one cluster.
3. Keep `ExternalSecret` resources close to the module that uses the secret.

Important rule:

- this chart installs the operator
- these examples show how to connect ESO to a secret backend
- the app that needs a Kubernetes `Secret` should define the matching `ExternalSecret` in its own values file

Files in this folder:

- `aws-secrets-manager-clustersecretstore.yaml`
- `azure-key-vault-clustersecretstore.yaml`
- `google-secret-manager-clustersecretstore.yaml`
- `hashicorp-vault-clustersecretstore.yaml`
- `ibm-cloud-secrets-manager-clustersecretstore.yaml`
- `cyberark-conjur-clustersecretstore.yaml`
- `consumer-external-secret.example.yaml`

Note:

- the CyberArk example uses the ESO `conjur` provider name

The provider examples use placeholder values. Replace them with real names, URLs, regions, tenant IDs, service accounts, and namespaces before you apply them.

Recommended use:

- create one or more central stores from these examples
- let consumer modules such as `identity-providers`, `user-workload-monitoring`, `cluster-logging`, `splunk-log-forwarding`, and `oadp-operator` define their own `externalSecrets` entries
