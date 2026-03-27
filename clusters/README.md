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
- `gitops.yaml`: list of GitOps apps for this cluster
- `values/*.yaml`: one values file per GitOps app

Use `enabled: true` or `enabled: false` in `gitops.yaml` to control whether an app is active.
In the sample clusters, only `external-secrets-operator` is enabled by default. Everything else is opt-in.

The sample files use neutral example values such as `apps.example.internal` and `cluster-admins@example.com`.
Replace those values before you merge your PR.

## Prepare Before Deployment

Before you open a deployment PR, make sure these items are ready:

- target AWS account, region, VPC, and Route53 base domain
- ROSA/OCM access for the automation identity
- cluster class selected or created in `catalog/cluster-classes/`
- complete `cluster.yaml` for the cluster instance
- complete `gitops.yaml` for the cluster instance
- values files for any GitOps apps you enable
- GitOps repository URL, revision, and credentials if private
- any required OADP, identity, RBAC, logging, monitoring, or Vault inputs for enabled applications
- CI secrets and access paths needed by the workflow

Do not expect CI to find every missing prerequisite. CI checks file structure and rendering, but your cloud, ROSA, DNS, and external service dependencies still need to be ready before merge.

## Validation

PR validation fails if:

- required keys are missing
- the referenced cluster class does not exist
- the referenced GitOps overlay does not exist
- business, network, ACM, or machine pool objects do not match the expected shape
- GitOps application paths do not exist or are missing `Chart.yaml`
- external Helm `valueFiles` entries do not exist or do not decode to YAML mappings

Keep shared defaults in `catalog/cluster-classes/`.
Keep cluster-specific values in `clusters/<environment>/<cluster>/`.
Set `enabled: true` only when you are ready to activate that module in the cluster.
