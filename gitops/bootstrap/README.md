# GitOps Bootstrap

Bootstrap content is the minimum GitOps footprint Terraform needs to seed.

## Contents

- `root-app/`: Helm chart that creates the environment root `Application`
- `root-app/values.example.yaml`: example values for local rendering only

## Flow

```text
Terraform bootstrap module
  -> root-app chart
  -> environment overlay
     -> platform apps
     -> workload apps
```

## Notes

- Terraform injects the repository URL, target revision, and stack-owned values into the root app
- environment overlays then render the child Argo CD `Application` objects
- `values.example.yaml` is illustrative only; it is not used by the factory workflow
