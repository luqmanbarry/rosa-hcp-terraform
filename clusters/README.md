# Clusters

Each directory under `clusters/` represents one cluster in one environment.

Users make changes here and open a pull request. CI validates the files, renders the final configuration, and saves audit artifacts. After approval and merge, CI runs Terraform and bootstraps OpenShift GitOps.

Put environment-specific settings in these cluster files. Put shared defaults in `catalog/cluster-classes/` or Terraform module defaults.

## Layout

```text
clusters/
  dev/
    cluster-01/
      cluster.yaml
      gitops.yaml
      values/
        self-provisioner.yaml
        user-workload-monitoring.yaml
        twistlock-defender-helm.yaml
```

What each file does:

- `cluster.yaml`: cluster settings such as region, networking, and machine pools
- `gitops.yaml`: list of GitOps apps for this cluster, including enablement and optional sync policy
- `values/*.yaml`: one values file per GitOps app

If the selected cluster class enables ACM registration, `cluster.yaml` should also include the `acm` block. That registration is optional bootstrap only. It does not move GitOps ownership to ACM.

Use `enabled: true` or `enabled: false` in `gitops.yaml` to control whether an app is active.
In the sample clusters, only `external-secrets-operator` is enabled by default. Everything else is opt-in.

You can also set an optional `syncPolicy` per app in `gitops.yaml` when a module should not use the default auto-sync behavior.

Important secret rule:

- if an app needs a Kubernetes `Secret`, define the matching `ExternalSecret` in that app's values file before you set `enabled: true`
- do not enable a secret-consuming app first and plan to add the secret later
- for ROSA, use AWS Secrets Manager as the default backend unless you have a clear reason to use a different provider

The sample files use neutral example values such as `apps.example.internal` and `cluster-admins@example.com`.
Replace those values before you merge your PR.

Some optional operator modules also ship with `subscription_channel: set-before-enable`.
That is intentional.
You must replace that value with a real supported channel before you set `enabled: true`.

## Prepare Before Deployment

Before you open a deployment PR, make sure these items are ready:

- target AWS account, region, VPC, subnets, and Route53 base domain
- customer AWS foundation already provisioned before this repo runs
- ROSA/OCM access for the automation identity
- cluster class selected or created in `catalog/cluster-classes/`
- complete `cluster.yaml` for the cluster instance
- complete `gitops.yaml` for the cluster instance
- values files for any GitOps apps you enable
- `SecretStore` or `ClusterSecretStore` ready for any app that uses External Secrets Operator
- AWS Secrets Manager access and ESO auth secret ready if you use the default ROSA secret pattern
- `externalSecrets` entries added to the values files of any enabled apps that need Kubernetes `Secret` objects
- GitOps repository URL, revision, and credentials if private
- any required OADP, identity, RBAC, logging, monitoring, or secret backend inputs for enabled applications
- CI secrets and access paths needed by the workflow

Do not expect CI to find every missing prerequisite. CI checks file structure and rendering, but your AWS foundation, ROSA, DNS, and external service dependencies still need to be ready before merge.

## Validation

PR validation fails if:

- required keys are missing
- the referenced cluster class does not exist
- the referenced GitOps overlay does not exist
- business, network, optional ACM, or machine pool objects do not match the expected shape
- GitOps application paths do not exist or are missing `Chart.yaml`
- external Helm `valueFiles` entries do not exist or do not decode to YAML mappings
- an enabled secret-consuming module references a `Secret` name that is not created by its own `externalSecrets` entries

Keep shared defaults in `catalog/cluster-classes/`.
Keep cluster-specific values in `clusters/<environment>/<cluster>/`.
Set `enabled: true` only when you are ready to activate that module in the cluster.
