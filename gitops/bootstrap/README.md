# GitOps Bootstrap

This folder contains the minimum GitOps content Terraform needs to start Argo CD.

## Contents

- `root-app/`: Helm chart that creates the cluster root `Application`
- `root-app/values.example.yaml`: example values for local rendering only

## Flow

```text
Terraform bootstrap module
  -> root-app chart
  -> shared overlay
     -> platform apps
     -> workload apps
```

## Notes

- Terraform injects the repository URL, target revision, and cluster values into the root app
- the shared overlay builds the child Argo CD applications from cluster-owned input
- `values.example.yaml` is illustrative only; it is not used by the factory workflow
