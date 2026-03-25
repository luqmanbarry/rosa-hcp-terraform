# Clusters

Each directory under `clusters/` represents one cluster instance in one environment.

Users propose changes by editing files under `clusters/` and opening a pull request. CI validates the change, renders the effective configuration, and produces audit artifacts. After approval and merge, CI applies Terraform and bootstraps OpenShift GitOps.

All environment-specific information should be parameterized in the cluster input files. Reusable defaults should live in `catalog/cluster-classes/` or module variable defaults.

## Layout

```text
clusters/
  dev/
    cluster-01/
      cluster.yaml
      gitops.yaml
```

`cluster.yaml` references a cluster class from `catalog/cluster-classes/`.
`gitops.yaml` owns the environment-specific App-of-Apps input for the GitOps overlay.

The sample cluster files in this repository use neutral example values such as `apps.example.internal` and `cluster-admins@example.com`.
Replace those with environment-specific values in your own PR before merging.

## Validation

PR validation rejects cluster inputs when:

- required keys are missing
- the referenced cluster class does not exist
- the referenced GitOps overlay does not exist
- business, network, ACM, or machine pool objects do not match the expected shape
- GitOps application paths do not exist or are missing `Chart.yaml`
- `helmValues` is present but does not decode to a YAML mapping

Keep defaults in `catalog/cluster-classes/` and only override per-cluster values in the cluster input files.
