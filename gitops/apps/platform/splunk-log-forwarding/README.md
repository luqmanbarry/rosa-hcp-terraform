# splunk-log-forwarding

This chart sends OpenShift logs to Splunk HEC.

Use it when:

- the cluster should forward logs to Splunk
- the Logging operator is already enabled
- a Splunk HEC token secret already exists in the target namespace

Important:

- this chart expects the logging operator and collector service account to already exist
- enable `cluster-logging` before you enable this chart
- define the matching `ExternalSecret` in the same values file if the Splunk token `Secret` must be created by External Secrets Operator

Examples:

- [`examples/secret-integration.values.example.yaml`](./examples/secret-integration.values.example.yaml)
- [`examples/externalsecrets.manifests.example.yaml`](./examples/externalsecrets.manifests.example.yaml)

AWS Secrets Manager is the active default example for ROSA. Other providers are included as commented alternatives.

Main inputs:

- `namespace`
- `clusterLogForwarderName`
- `serviceAccountName`
- `output.url`
- `output.secretName`
- `output.secretKey`
- `pipelines`
