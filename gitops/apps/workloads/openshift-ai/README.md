# OpenShift AI

This chart installs Red Hat OpenShift AI Self-Managed with a production-oriented baseline:

- installs the `rhods-operator`
- creates `DSCInitialization` and `DataScienceCluster` custom resources
- enables hardware profiles in the dashboard and disables deprecated accelerator profiles
- defaults Kueue integration to `Unmanaged`, which aligns with the current deprecation guidance for embedded Kueue

This module is intended to pair with dedicated ROSA worker pools labeled for AI workloads, for example:

- `workload.platform/ai=true`

Default placement behavior is unconstrained:

- if you do not provide AI-specific scheduling manifests, OpenShift AI workloads use the default worker pool
- if you want AI workloads on dedicated worker pools, add machine-pool labels such as `workload.platform/ai=true` and supply corresponding manifests through `hardwareProfiles`

The `hardwareProfiles` value is a raw-manifest extension point for version-specific `HardwareProfile` or related scheduling resources. This avoids hardcoding an unverified CRD schema into the repo while still letting you manage hardware-profile resources through GitOps.
